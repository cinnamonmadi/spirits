extends Node2D

onready var director = get_node("/root/Director")

onready var enemy_health = $enemy_health
onready var enemy_name_label = $enemy_health/label_name
onready var enemy_health_label = $enemy_health/label_health
onready var enemy_mana_label = $enemy_health/label_mana

onready var player_health = $player_health
onready var player_name_label = $player_health/label_name
onready var player_health_label = $player_health/label_health
onready var player_mana_label = $player_health/label_mana

onready var enemy_sprite = $familiar_enemy
onready var player_sprite = $familiar_player

onready var dialog = $dialog
onready var battle_actions = $battle_actions
onready var move_select = $move_select
onready var move_info = $move_info
onready var party_menu = $party_menu
onready var runaway_choices = $runaway_choices

enum State {
    SPRITES_ENTERING,
    ANNOUNCE_OPPONENT,
    CALLOUT_FAMILIAR,
    CALLBACK_FAMILIAR,
    SUMMON_FAMILIAR,
    CHOOSE_ACTION,
    CHOOSE_MOVE,
    PARTY_MENU,
    ANNOUNCE_MOVE,
    ANIMATE_MOVE,
    EXECUTE_MOVE,
    EVALUATE,
    FAINT,
    PROMPT_ESCAPE,
    OPTIONS_ESCAPE,
    ANNOUNCE_WINNER
}

var state = State.SPRITES_ENTERING
var enemy_familiar
var timer: float

const SCREEN_WIDTH = 160

# Intro sprites entering
const SPRITE_ENTER_DURATION: float = 1.5
var player_sprite_start_x: int
var player_sprite_position: Vector2
var enemy_sprite_start_x: int
var enemy_sprite_position: Vector2

# Battle commence moves
var player_chosen_move: String
var enemy_chosen_move: String
var turns = []
var current_turn: int = 0

# Battle animate move
const ANIMATE_MOVE_DURATION: float = 0.3
const ANIMATE_MOVE_DISTANCE: int = 10

# Battle execute move
const EXECUTE_MOVE_DURATION: float = 0.3
var player_old_hp: int = 0
var player_old_mp: int = 0
var enemy_old_hp: int = 0
var enemy_old_mp: int = 0

# Battle faint
const FAINT_DURATION: float = 1.0

var rand = RandomNumberGenerator.new()

func _ready():
    rand.randomize()

    enemy_familiar = Familiar.new()
    enemy_familiar.species = "SPHYNX"
    enemy_familiar.moves = ["SPOOK", "TAUNT", "EMBER", "BASK"]
    enemy_familiar.health = 5
    enemy_familiar.max_health = 5
    enemy_familiar.mana = 10
    enemy_familiar.max_mana = 10

    dialog.keep_open = true
    dialog.DIALOG_SPEED = (1.0 / 60)
    dialog.open_empty()

    # This check will not be needed eventually, but for developing, let's check to make sure the player even has a familiar living
    if director.is_player_wiped():
        set_state(State.ANNOUNCE_WINNER)
    else:
        if director.player_familiars[0].health <= 0:
            for i in range(1, director.player_familiars.size()):
                if director.player_familiars[i].health > 0:
                    director.player_switch_familiars(0, i)
                    break

    update_healthbars(0.0)
    set_state(State.SPRITES_ENTERING)

func set_state(new_state):
    if state == State.CALLOUT_FAMILIAR:
        init_healthbars()
        player_sprite.visible = true
        player_health.visible = true

    state = new_state

    battle_actions.close()
    move_select.close()
    move_info.close()
    party_menu.close()
    runaway_choices.close()

    if state == State.SPRITES_ENTERING:
        player_sprite.visible = false
        enemy_health.visible = false
        player_health.visible = false

        player_sprite_position = player_sprite.position
        player_sprite_start_x = SCREEN_WIDTH + (player_sprite.texture.get_size().x / 2)
        enemy_sprite_position = enemy_sprite.position
        enemy_sprite_start_x = -(enemy_sprite.texture.get_size().x / 2)

        timer = SPRITE_ENTER_DURATION
    elif state == State.ANNOUNCE_OPPONENT:
        dialog.open("A wild " + enemy_familiar.get_display_name() + " appeared!")
    elif state == State.CALLOUT_FAMILIAR:
        enemy_health.visible = true
        dialog.open("Go! " + director.player_familiars[0].get_display_name() + "!")
    elif state == State.CALLBACK_FAMILIAR:
        player_sprite.visible = false
        player_health.visible = false
        dialog.open(director.player_familiars[0].get_display_name() + "! Come back!")
    elif state == State.SUMMON_FAMILIAR:
        timer = 1.0
    elif state == State.CHOOSE_ACTION:
        dialog.open_empty()
        battle_actions.open()
    elif state == State.CHOOSE_MOVE:
        dialog.open_empty()
        move_select.set_labels([director.player_familiars[0].moves])
        move_select.open()
        open_move_info(move_select.select())
    elif state == State.PARTY_MENU:
        party_menu.open(true)
    elif state == State.ANNOUNCE_MOVE:
        if turns[current_turn] == "player":
            dialog.open_with([[director.player_familiars[0].get_display_name(), "used " + player_chosen_move]])
        elif turns[current_turn] == "enemy":
            dialog.open_with([["Enemy " + enemy_familiar.get_display_name(), "used " + enemy_chosen_move]])
    elif state == State.ANIMATE_MOVE:
        timer = ANIMATE_MOVE_DURATION
    elif state == State.EXECUTE_MOVE:
        setup_execute_move()
        timer = EXECUTE_MOVE_DURATION
    elif state == State.EVALUATE:
        evaluate_move()
    elif state == State.FAINT:
        timer = FAINT_DURATION
        if turns[current_turn] == "player":
            dialog.open_with([["Enemy " + enemy_familiar.get_display_name(), "fainted!"]])
        elif turns[current_turn] == "enemy":
            dialog.open_with([[director.player_familiars[0].get_display_name(), "fainted!"]])
    elif state == State.PROMPT_ESCAPE:
        dialog.open("Will you change familiars?")
    elif state == State.OPTIONS_ESCAPE:
        runaway_choices.open()
    elif state == State.ANNOUNCE_WINNER:
        if turns[current_turn] == "player":
            dialog.open("You win!")
        elif turns[current_turn] == "enemy":
            dialog.open("You lose...")

func open_move_info(move: String):
    var move_info_values = Familiar.MOVE_INFO[move]
    move_info.open(move_info_values["type"], String(move_info_values["cost"]) + " MP")

func init_healthbars():
    enemy_sprite.texture = load(enemy_familiar.get_portrait_path())
    enemy_name_label.text = enemy_familiar.get_display_name()

    player_sprite.texture = load(director.player_familiars[0].get_portrait_path())
    player_name_label.text = director.player_familiars[0].get_display_name()

    update_healthbars(0)

func update_bar(bar_label, prefix, old_value, new_value, max_value, percent_complete):
    var value: int
    if percent_complete <= 0 or new_value == old_value:
        value = new_value
    else:
        var difference = abs(new_value - old_value)
        if new_value > old_value:
            value = old_value + (difference * percent_complete)
        else:
            value = old_value - (difference * percent_complete)
    bar_label.text = prefix + String(value) + "/" + String(max_value)

func update_healthbars(percent_complete=0.0):
    update_bar(player_health_label, "HP: ", player_old_hp, director.player_familiars[0].health, director.player_familiars[0].max_health, percent_complete)
    update_bar(player_mana_label, "MP: ", player_old_mp, director.player_familiars[0].mana, director.player_familiars[0].max_mana, percent_complete)
    update_bar(enemy_health_label, "HP: ", enemy_old_hp, enemy_familiar.health, enemy_familiar.max_health, percent_complete)
    update_bar(enemy_mana_label, "MP: ", enemy_old_mp, enemy_familiar.mana, enemy_familiar.max_mana, percent_complete)

func setup_turn(player_move: String):
    player_chosen_move = player_move
    enemy_chosen_move = enemy_familiar.moves[rand.randi_range(0, 3)]
    if director.player_familiars[0].speed >= enemy_familiar.speed:
        turns = ["player", "enemy"]
    else:
        turns = ["enemy", "player"]
    current_turn = 0

func _process(delta):
    if state == State.SPRITES_ENTERING:
        timer -= delta
        if timer <= 0:
            enemy_sprite.position.x = enemy_sprite_position.x
            player_sprite.position.x = player_sprite_position.x
            set_state(State.ANNOUNCE_OPPONENT)
        else:
            enemy_sprite.position.x = enemy_sprite_start_x + ((enemy_sprite_position.x - enemy_sprite_start_x) * (1 - (timer / SPRITE_ENTER_DURATION)))
            player_sprite.position.x = player_sprite_start_x - ((player_sprite_start_x - player_sprite_position.x) * (1 - (timer / SPRITE_ENTER_DURATION)))
    elif state == State.ANNOUNCE_OPPONENT:
        if dialog.is_waiting() and Input.is_action_just_pressed("action"):
            set_state(State.CALLOUT_FAMILIAR)
    elif state == State.CALLOUT_FAMILIAR:
        if dialog.is_waiting():
            set_state(State.SUMMON_FAMILIAR)
    elif state == State.CALLBACK_FAMILIAR:
        if dialog.is_waiting():
            director.player_switch_familiars(0, party_menu.battle_switch_index)
            set_state(State.CALLOUT_FAMILIAR)
    elif state == State.SUMMON_FAMILIAR:
        timer -= delta
        if timer <= 0:
            set_state(State.CHOOSE_ACTION)
    elif state == State.CHOOSE_ACTION:
        var action = battle_actions.check_for_input()
        if action == "FIGHT":
            set_state(State.CHOOSE_MOVE)
        elif action == "PARTY":
            set_state(State.PARTY_MENU)
    elif state == State.CHOOSE_MOVE:
        if Input.is_action_just_pressed("back"):
            set_state(State.CHOOSE_ACTION)
        else:
            var move = move_select.check_for_input()
            if move == "":
                open_move_info(move_select.select())
            else:
                setup_turn(move)
                set_state(State.ANNOUNCE_MOVE)
    elif state == State.PARTY_MENU:
        party_menu.check_for_input()
        if party_menu.is_closed():
            # Check if the player actually switched familiars
            if party_menu.battle_switch_index != -1:
                # Skip the callback familiar if your familiar is already dead
                if director.player_familiars[0].health <= 0:
                    director.player_switch_familiars(0, party_menu.battle_switch_index)
                    set_state(State.CALLOUT_FAMILIAR)
                else:
                    set_state(State.CALLBACK_FAMILIAR)
            else:
                # If familiar is dead, return to prompt escape selection
                if director.player_familiars[0].health <= 0:
                    set_state(State.PROMPT_ESCAPE)
                # Otherwise return to choose action screen
                else:
                    set_state(State.CHOOSE_ACTION)
    elif state == State.ANNOUNCE_MOVE:
        if dialog.is_waiting():
            set_state(State.ANIMATE_MOVE)
    elif state == State.ANIMATE_MOVE:
        timer -= delta
        if timer <= 0:
            if turns[current_turn] == "player":
                player_sprite.position.x = player_sprite_position.x
            elif turns[current_turn] == "enemy":
                enemy_sprite.position.x = enemy_sprite_position.x
            set_state(State.EXECUTE_MOVE)
        else:
            var moving_forward = timer >= (ANIMATE_MOVE_DURATION / 2)
            var movement_percent: float 
            if moving_forward:
                movement_percent = 1 - ((timer - (ANIMATE_MOVE_DURATION / 2)) / (ANIMATE_MOVE_DURATION / 2))
            else:
                movement_percent = (timer / (ANIMATE_MOVE_DURATION / 2))
            if turns[current_turn] == "player":
                player_sprite.position.x = player_sprite_position.x + (ANIMATE_MOVE_DISTANCE * movement_percent)
            elif turns[current_turn] == "enemy":
                enemy_sprite.position.x = enemy_sprite_position.x - (ANIMATE_MOVE_DISTANCE * movement_percent)
    elif state == State.EXECUTE_MOVE:
        timer -= delta
        if timer <= 0:
            update_healthbars(0)
            set_state(State.EVALUATE)
        else:
            var percent_complete = 1 - (timer / EXECUTE_MOVE_DURATION)
            update_healthbars(percent_complete)
    elif state == State.FAINT:
        timer -= delta
        if timer <= 0:
            if turns[current_turn] == "player":
                enemy_sprite.visible = false
                enemy_health.visible = false
            elif turns[current_turn] == "enemy":
                player_sprite.visible = false
                player_health.visible = false
        if timer <= 0 and Input.is_action_just_pressed("action") and dialog.is_waiting():
            if turns[current_turn] == "enemy" and not director.is_player_wiped():
                set_state(State.PROMPT_ESCAPE)
            else:
                set_state(State.ANNOUNCE_WINNER)
    elif state == State.PROMPT_ESCAPE:
        if dialog.is_waiting() and Input.is_action_just_pressed("action"):
            set_state(State.OPTIONS_ESCAPE)
    elif state == State.OPTIONS_ESCAPE:
        var action = runaway_choices.check_for_input()
        if action == "SWITCH":
            set_state(State.PARTY_MENU)
        elif action == "RUN":
            pass
            # try running
    elif state == State.ANNOUNCE_WINNER:
        if Input.is_action_just_pressed("action") and dialog.is_waiting():
            print("hey")
            director.end_battle()

func setup_execute_move():
    player_old_hp = director.player_familiars[0].health
    player_old_mp = director.player_familiars[0].mana
    enemy_old_hp = enemy_familiar.health
    enemy_old_mp = enemy_familiar.mana

    if turns[current_turn] == "player":
        director.player_familiars[0].use_move(player_chosen_move, enemy_familiar)
    elif turns[current_turn] == "enemy":
        enemy_familiar.use_move(enemy_chosen_move, director.player_familiars[0])

func evaluate_move():
    if (turns[current_turn] == "player" and enemy_familiar.health == 0) or (turns[current_turn] == "enemy" and director.player_familiars[0].health == 0):
        set_state(State.FAINT)
        return

    current_turn += 1
    if current_turn == 2:
        set_state(State.CHOOSE_ACTION)
    else:
        set_state(State.ANNOUNCE_MOVE)
