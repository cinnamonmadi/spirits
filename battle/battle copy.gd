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
onready var timer = $timer

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

func _ready():
    enemy_familiar = Familiar.new("SPHYNX", 3)

    dialog.keep_open = true
    dialog.DIALOG_SPEED = (1.0 / 60)
    dialog.open_empty()

    # This check will not be needed eventually, but for developing, let's check to make sure the player even has a familiar living
    if director.is_player_wiped():
        set_state(State.ANNOUNCE_WINNER)
    else:
        if director.player_party.familiars[0].health <= 0:
            for i in range(1, director.player_party.familiars.size()):
                if director.player_party.familiars[i].health > 0:
                    director.player_switch_familiars(0, i)
                    break

    update_healthbars(0.0)
    set_state(State.SPRITES_ENTERING)

func set_state(new_state):
    close_all()
    state = new_state
    var state_name = State.keys()[state].to_lower()
    var state_begin_function = "begin_" + state_name
    call(state_begin_function)

func _process(_delta):
    var state_name = State.keys()[state].to_lower()
    var state_process_function = "process_" + state_name
    call(state_process_function)

func open_move_info(move: String):
    var move_info_values = Familiar.MOVE_INFO[move]
    move_info.open(move_info_values["type"], String(move_info_values["cost"]) + " MP")

func init_healthbars():
    enemy_sprite.texture = load(enemy_familiar.get_portrait_path())
    enemy_name_label.text = enemy_familiar.get_display_name()

    player_sprite.texture = load(director.player_party.familiars[0].get_portrait_path())
    player_name_label.text = director.player_party.familiars[0].get_display_name()

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
    update_bar(player_health_label, "HP: ", player_old_hp, director.player_party.familiars[0].health, director.player_party.familiars[0].max_health, percent_complete)
    update_bar(player_mana_label, "MP: ", player_old_mp, director.player_party.familiars[0].mana, director.player_party.familiars[0].max_mana, percent_complete)
    update_bar(enemy_health_label, "HP: ", enemy_old_hp, enemy_familiar.health, enemy_familiar.max_health, percent_complete)
    update_bar(enemy_mana_label, "MP: ", enemy_old_mp, enemy_familiar.mana, enemy_familiar.max_mana, percent_complete)

func init_turn(player_move: String):
    player_chosen_move = player_move
    enemy_chosen_move = enemy_familiar.moves[director.rng.randi_range(0, 3)]
    if director.player_party.familiars[0].speed >= enemy_familiar.speed:
        turns = ["player", "enemy"]
    else:
        turns = ["enemy", "player"]
    current_turn = 0

func close_all():
    battle_actions.close()
    move_select.close()
    move_info.close()
    party_menu.close()
    runaway_choices.close()

func begin_sprites_entering():
    player_health.visible = false
    enemy_health.visible = false
    player_sprite.visible = false

    player_sprite_position = player_sprite.position
    player_sprite_start_x = SCREEN_WIDTH + (player_sprite.texture.get_size().x / 2)
    enemy_sprite_position = enemy_sprite.position
    enemy_sprite_start_x = -(enemy_sprite.texture.get_size().x / 2)

    timer.start(SPRITE_ENTER_DURATION)

func process_sprites_entering():
    var percent_complete: float = 1 - (timer.get_time_left() / SPRITE_ENTER_DURATION)
    enemy_sprite.position.x = enemy_sprite_start_x + ((enemy_sprite_position.x - enemy_sprite_start_x) * percent_complete)
    player_sprite.position.x = player_sprite_start_x - ((player_sprite_start_x - player_sprite_position.x) * percent_complete)
    if timer.is_stopped():
        enemy_sprite.position.x = enemy_sprite_position.x
        player_sprite.position.x = player_sprite_position.x
        enemy_health.visible = true
        set_state(State.ANNOUNCE_OPPONENT)

func begin_announce_opponent():
    dialog.open("A wild " + enemy_familiar.get_display_name() + " appeared!")

func process_announce_opponent():
    if dialog.is_waiting() and Input.is_action_just_pressed("action"):
        set_state(State.CALLOUT_FAMILIAR)

func begin_callout_familiar():
    dialog.open("Go! " + director.player_party.familiars[0].get_display_name() + "!")

func process_callout_familiar():
    if dialog.is_waiting():
        init_healthbars()
        player_sprite.visible = true
        player_health.visible = true
        set_state(State.SUMMON_FAMILIAR)

func begin_callback_familiar():
    player_sprite.visible = false
    player_health.visible = false
    dialog.open(director.player_party.familiars[0].get_display_name() + "! Come back!")

func process_callback_familiar():
    if dialog.is_waiting():
        director.player_switch_familiars(0, party_menu.battle_switch_index)
        set_state(State.CALLOUT_FAMILIAR)

func begin_summon_familiar():
    timer.start(1.0)

func process_summon_familiar():
    if timer.is_stopped():
        set_state(State.CHOOSE_ACTION)

func begin_choose_action():
    dialog.open_empty()
    battle_actions.open()

func process_choose_action():
    var action = battle_actions.check_for_input()
    if action == "FIGHT":
        set_state(State.CHOOSE_MOVE)
    elif action == "PARTY":
        set_state(State.PARTY_MENU)

func begin_choose_move():
    dialog.open_empty()
    move_select.set_labels([director.player_party.familiars[0].moves])
    move_select.open()
    open_move_info(move_select.select())

func process_choose_move():
    if Input.is_action_just_pressed("back"):
        set_state(State.CHOOSE_ACTION)
    else:
        var move = move_select.check_for_input()
        if move == "":
            open_move_info(move_select.select())
        else:
            var move_info_values = Familiar.MOVE_INFO[move]
            var can_use_move: bool = director.player_party.familiars[0].mana >= move_info_values["cost"]
            if not can_use_move:
                return
            init_turn(move)
            set_state(State.ANNOUNCE_MOVE)

func begin_party_menu():
    party_menu.open(true)

func process_party_menu():
    party_menu.check_for_input()
    if party_menu.is_closed():
        # Check if the player actually switched familiars
        if party_menu.battle_switch_index != -1:
            # Skip the callback familiar if your familiar is already dead
            if director.player_party.familiars[0].health <= 0:
                director.player_switch_familiars(0, party_menu.battle_switch_index)
                set_state(State.CALLOUT_FAMILIAR)
            else:
                set_state(State.CALLBACK_FAMILIAR)
        else:
            # If familiar is dead, return to prompt escape selection
            if director.player_party.familiars[0].health <= 0:
                set_state(State.PROMPT_ESCAPE)
            # Otherwise return to choose action screen
            else:
                set_state(State.CHOOSE_ACTION)

func begin_announce_move():
    if turns[current_turn] == "player":
        dialog.open_with([[director.player_party.familiars[0].get_display_name(), "used " + player_chosen_move]])
    elif turns[current_turn] == "enemy":
        dialog.open_with([["Enemy " + enemy_familiar.get_display_name(), "used " + enemy_chosen_move]])

func process_announce_move():
    if dialog.is_waiting():
        set_state(State.ANIMATE_MOVE)

func begin_animate_move():
    timer.start(ANIMATE_MOVE_DURATION)

func process_animate_move():
    var half_duration = ANIMATE_MOVE_DURATION / 2
    var moving_forward: bool = timer.get_time_left() >= half_duration 
    var movement_percent: float 
    if moving_forward:
        movement_percent = 1 - ((timer.get_time_left() - half_duration) / half_duration)
    else:
        movement_percent = timer.get_time_left() / half_duration 
    if turns[current_turn] == "player":
        player_sprite.position.x = player_sprite_position.x + (ANIMATE_MOVE_DISTANCE * movement_percent)
    elif turns[current_turn] == "enemy":
        enemy_sprite.position.x = enemy_sprite_position.x - (ANIMATE_MOVE_DISTANCE * movement_percent)

    if timer.is_stopped():
        set_state(State.EXECUTE_MOVE)

func begin_execute_move():
    player_old_hp = director.player_party.familiars[0].health
    player_old_mp = director.player_party.familiars[0].mana
    enemy_old_hp = enemy_familiar.health
    enemy_old_mp = enemy_familiar.mana

    var attacker
    var defender
    var move
    if turns[current_turn] == "player":
        attacker = director.player_party.familiars[0]
        defender = enemy_familiar
        move = player_chosen_move
    elif turns[current_turn] == "enemy":
        defender = director.player_party.familiars[0]
        attacker = enemy_familiar
        move = enemy_chosen_move

    var chosen_move_info = Familiar.MOVE_INFO[move]

    var base_damage = int((((2.0 * attacker.level) / 5.0) * chosen_move_info["power"] * (float(attacker.attack) / float(defender.defense))) / 50.0) + 2
    var random_mod = director.rng.randf_range(0.85, 1.0)
    var damage = base_damage * random_mod

    defender.health = max(defender.health - damage, 0)
    attacker.mana = max(attacker.mana - chosen_move_info["cost"], 0)

    timer.start(EXECUTE_MOVE_DURATION)

func process_execute_move():
    var percent_complete = timer.get_time_left() / EXECUTE_MOVE_DURATION
    update_healthbars(percent_complete)
    if timer.is_stopped():
        evaluate_fight_status()

func begin_faint():
    timer.start(FAINT_DURATION)
    if turns[current_turn] == "player":
        dialog.open_with([["Enemy " + enemy_familiar.get_display_name(), "fainted!"]])
    elif turns[current_turn] == "enemy":
        dialog.open_with([[director.player_party.familiars[0].get_display_name(), "fainted!"]])

func process_faint():
    if timer.is_stopped():
        if turns[current_turn] == "player":
            enemy_sprite.visible = false
            enemy_health.visible = false
        elif turns[current_turn] == "enemy":
            player_sprite.visible = false
            player_health.visible = false
    if timer.is_stopped() and dialog.is_waiting() and Input.is_action_just_pressed("action"):
        if turns[current_turn] == "enemy" and not director.is_player_wiped():
            set_state(State.PROMPT_ESCAPE)
        else:
            set_state(State.ANNOUNCE_WINNER)

func begin_prompt_escape():
    dialog.open("Will you change familiars?")

func process_prompt_escape():
    if dialog.is_waiting() and Input.is_action_just_pressed("action"):
        set_state(State.OPTIONS_ESCAPE)

func begin_options_escape():
    runaway_choices.open()

func process_options_escape():
    var action = runaway_choices.check_for_input()
    if action == "SWITCH":
        set_state(State.PARTY_MENU)
    elif action == "RUN":
        pass
        # try running
    
func begin_announce_winner():
    if turns[current_turn] == "player":
        dialog.open("You win!")
    elif turns[current_turn] == "enemy":
        dialog.open("You lose...")

func process_announce_winner():
    if Input.is_action_just_pressed("action") and dialog.is_waiting():
        director.end_battle()

func evaluate_fight_status():
    if (turns[current_turn] == "player" and enemy_familiar.health == 0) or (turns[current_turn] == "enemy" and director.player_party.familiars[0].health == 0):
        set_state(State.FAINT)
        return

    current_turn += 1
    if current_turn == 2:
        set_state(State.CHOOSE_ACTION)
    else:
        set_state(State.ANNOUNCE_MOVE)
