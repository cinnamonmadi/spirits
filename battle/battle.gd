extends Node2D

class_name Battle

onready var director = get_node("/root/Director")

onready var witch = $witch
onready var enemy_sprites = $enemy_sprites
onready var player_sprites = $player_sprites
onready var enemy_labels = $ui/enemy_labels
onready var player_labels = $ui/player_labels

onready var action_select = $ui/action_select
onready var battle_dialog = $ui/battle_dialog
onready var party_menu = $ui/party_menu
onready var target_cursor = $ui/target_cursor
onready var centered_familiar = $ui/centered_familiar
onready var dialog = $ui/dialog
onready var dialog_yes_no = $ui/dialog_yes_no
onready var namebox = $ui/namebox

onready var tween = $tween
onready var timer = $timer

const SCREEN_WIDTH: int = 640
const BATTLE_DIALOG_WAIT_TIME: float = 0.5

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
              ChooseTarget.new(),
              BeginTurn.new(),
              AnimateMove.new(),
              ExecuteMove.new(),
              EvaluateMove.new(),
              AnnounceWinner.new(),
              NameFamiliar.new(),
              LearnMove.new()]

var enemy_captured = []
var actions = []
var chosen_item = 0
var rests = []
var targeting_for_action

func _ready():
    tween.connect("tween_all_completed", self, "_on_tween_finish")
    timer.connect("timeout", self, "_on_timer_timeout")
    for state_node in states:
        add_child(state_node)

    for _i in range(0, director.enemy_party.familiars.size()):
        enemy_captured.append(false)

    battle_dialog.ROW_CHAR_LEN = 18
    battle_dialog.DIALOG_SPEED /= 3.0
    battle_dialog.keep_open = true

    close_all_menus()
    director.player_party.pre_battle_setup()
    director.enemy_party.pre_battle_setup()
    set_state(State.SPRITES_ENTERING, {})

func get_enemy_living_familiar_count():
    var count = 0
    for i in range(0, director.enemy_party.familiars.size()):
        if not enemy_captured[i] and director.enemy_party.familiars[i].is_living():
            count += 1
    return count

func close_all_menus():
    action_select.close()
    battle_dialog.close()
    party_menu.close()
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
        return director.enemy_party.familiars[action.familiar]

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
    enemy_labels.get_child(child_index).set_familiar(director.enemy_party.familiars[i])
    enemy_labels.get_child(child_index).visible = true

func recharge_energy():
    for familiar in director.player_party.familiars:
        recharge_familiar_energy(familiar)
    for familiar in director.enemy_party.familiars:
        recharge_familiar_energy(familiar)

func recharge_familiar_energy(familiar: Familiar):
    if not familiar.is_living():
        return
    if familiar.burnout != 0:
        familiar.burnout = 0
        familiar.is_burnedout = true
        return
    if familiar.is_burnedout:
        familiar.is_burnedout = false
    var percent_of_focus = 0.05
    if familiar.is_resting:
        percent_of_focus += 0.15
        familiar.is_resting = false
    var mana_to_recharge = int(ceil(float(familiar.focus) * percent_of_focus) + 1)
    familiar.change_mana(mana_to_recharge)
