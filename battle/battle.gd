extends Node2D

class_name Battle

onready var director = get_node("/root/Director")
onready var familiar_factory = get_node("/root/FamiliarFactory")

onready var witch = $witch
onready var enemy_sprites = $enemy_sprites
onready var player_sprites = $player_sprites
onready var enemy_labels = $enemy_labels
onready var player_labels = $player_labels

onready var battle_actions = $ui/battle_actions
onready var move_select = $ui/move_select
onready var move_info = $ui/move_info
onready var party_menu = $ui/party_menu
onready var move_callout = $ui/move_callout
onready var target_cursor = $ui/target_cursor
onready var centered_familiar = $ui/centered_familiar
onready var dialog = $ui/dialog
onready var dialog_yes_no = $ui/dialog_yes_no
onready var namebox = $ui/namebox

onready var tween = $tween
onready var timer = $timer

const SCREEN_WIDTH: int = 640

const State = preload("res://battle/states/states.gd")

enum SurpriseRound {
    NONE,
    PLAYER,
    ENEMY
}

var state = State.SPRITES_ENTERING
var states = [SpritesEntering.new(),
              SummonFamiliar.new(),
              ChooseAction.new(),
              PartyMenu.new(),
              ItemMenu.new(),
              ChooseMove.new(),
              ChooseTarget.new(),
              BeginTurn.new(),
              AnimateMove.new(),
              ExecuteMove.new(),
              EvaluateMove.new(),
              AnnounceWinner.new(),
              NameFamiliar.new(),
              LearnMove.new()]

var surprise_round = "none"
var enemy_party = Party.new()
var enemy_captured = []
var actions = []
var current_turn = -1
var chosen_item = 0
var targeting_for_action

func _ready():
    tween.connect("tween_all_completed", self, "_on_tween_finish")
    timer.connect("timeout", self, "_on_timer_timeout")
    for state_node in states:
        add_child(state_node)

    enemy_party.familiars.append(familiar_factory.create_familiar(familiar_factory.Species.GHOST, 3))
    enemy_party.familiars.append(familiar_factory.create_familiar(familiar_factory.Species.MIMIC, 3))
    for familiar in enemy_party.familiars:
        familiar.health = 1
    for _i in range(0, enemy_party.familiars.size()):
        enemy_captured.append(false)

    close_all_menus()
    director.player_party.pre_battle_setup()
    if surprise_round == "player":
        open_move_callout("AMBUSH!")
    elif surprise_round == "enemy":
        open_move_callout("SURROUNDED!")
    set_state(State.SPRITES_ENTERING, {})

func close_all_menus():
    set_actions_menu_frame(-1)
    move_select.close()
    move_info.close()
    party_menu.close()
    move_callout.visible = false
    target_cursor.visible = false
    centered_familiar.visible = false
    dialog.close()
    dialog_yes_no.close()
    namebox.visible = false

func set_state(new_state, params):
    state = new_state
    states[state].begin(params)

func _on_tween_finish():
    states[state].handle_tween_finish()

func _on_timer_timeout():
    states[state].handle_timer_timeout()

func _process(_delta):
    states[state].process(_delta)

func get_acting_familiar(action):
    if action.who == "player":
        return director.player_party.familiars[action.familiar]
    else:
        return enemy_party.familiars[action.familiar]

func get_choosing_familiar_index():
    var index = actions.size()
    if not director.player_party.familiars[index].is_living():
        index += 1
    return index

func update_player_label(i):
    player_labels.get_child(i).set_familiar(director.player_party.familiars[i])
    player_labels.get_child(i).visible = true

func hide_all_enemy_labels():
    for child in enemy_labels.get_children():
        child.visible = false

func update_enemy_label(i):
    var child_index = enemy_labels.get_child_count() - 1 - i
    enemy_labels.get_child(child_index).set_familiar(enemy_party.familiars[i])
    enemy_labels.get_child(child_index).visible = true

func set_target_cursor(target_who: String, target_index: int):
    var offset_direction = 1
    var cursor_base_position
    if target_who == "player":
        cursor_base_position = player_sprites.rect_position + player_sprites.get_child(target_index).position
        offset_direction = -1
    else:
        cursor_base_position = enemy_sprites.rect_position + enemy_sprites.get_child(3 - target_index).position

    target_cursor.flip_v = target_who == "player"
    target_cursor.position = cursor_base_position + Vector2(0, 80 * offset_direction)
    target_cursor.visible = true

func open_move_callout(move: String):
    move_callout.get_child(0).text = move
    move_callout.visible = true

func set_actions_menu_frame(frame: int):
    if frame == -1:
        battle_actions.visible = false
    else: 
        battle_actions.visible = true
        battle_actions.frame = frame
