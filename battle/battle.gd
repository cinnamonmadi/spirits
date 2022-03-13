extends Node2D

class_name Battle

onready var director = get_node("/root/Director")

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

onready var tween = $tween
onready var timer = $timer

const SCREEN_WIDTH: int = 640

const State = preload("res://battle/states/states.gd")

var state = State.SPRITES_ENTERING
var states = [SpritesEntering.new(),
              SummonFamiliar.new(),
              ChooseAction.new(),
              PartyMenu.new(),
              ChooseMove.new(),
              ChooseTarget.new(),
              BeginTurn.new(),
              AnimateMove.new(),
              ExecuteMove.new(),
              EvaluateMove.new(),
              AnnounceWinner.new()]
var enemy_party = Party.new()
var actions = []
var player_choosing_index
var chosen_move = 0
var current_turn = -1

func _ready():
    tween.connect("tween_all_completed", self, "_on_tween_finish")
    for state_node in states:
        add_child(state_node)

    enemy_party.familiars.append(Familiar.new(Familiar.Species.GHOST, 5))
    enemy_party.familiars.append(Familiar.new(Familiar.Species.MIMIC, 5))

    close_all_menus()
    director.player_party.sort_fighters_first()
    set_state(State.SPRITES_ENTERING)

func close_all_menus():
    battle_actions.close()
    move_select.close()
    move_info.close()
    party_menu.close()
    move_callout.visible = false
    target_cursor.visible = false

func set_state(new_state):
    state = new_state
    states[state].begin()

func _on_tween_finish():
    states[state].handle_tween_finish()

func _process(_delta):
    states[state].process(_delta)

func get_acting_familiar(action):
    if action.who == "player":
        return director.player_party.familiars[action.familiar]
    else:
        return enemy_party.familiars[action.familiar]

func update_player_label(i):
    player_labels.get_child(i).text = director.player_party.familiars[i].get_display_name()
    player_labels.get_child(i).get_child(0).text = "HP " + String(director.player_party.familiars[i].health) + " MP " + String(director.player_party.familiars[i].mana)
    player_labels.get_child(i).visible = true

func hide_all_enemy_labels():
    for child in enemy_labels.get_children():
        child.visible = false

func update_enemy_label(i):
    var child_index = enemy_labels.get_child_count() - 1 - i
    enemy_labels.get_child(child_index).text = "HP " + String(enemy_party.familiars[i].health)
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
