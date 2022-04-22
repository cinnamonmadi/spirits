extends Node
class_name SummonFamiliar

onready var director = get_node("/root/Director")
onready var familiar_factory = get_node("/root/FamiliarFactory")

onready var player_sprites = get_parent().get_node("player_sprites")
onready var tween = get_parent().get_node("tween")
onready var witch = get_parent().get_node("witch")
onready var battle_dialog = get_parent().get_node("ui/battle_dialog")

const WITCH_EXIT_DURATION: float = 0.5

const State = preload("res://battle/states/states.gd")

func begin(params):
    if params.trigger_witch_exit:
        tween.interpolate_property(witch, "position", witch.position, witch.position - Vector2(witch.texture.get_size().x, 0), WITCH_EXIT_DURATION)
        tween.start()
    if params.who == "player":
        var summoning_familiars = []
        for familiar_index in range(0, 2):
            if not player_sprites.get_child(familiar_index).visible:
                summoning_familiars.append(director.player_party.familiars[familiar_index])
        var dialog_message = ""
        for i in range(0, summoning_familiars.size()):
            if i != 0:
                dialog_message += " "
            dialog_message += familiar_factory.get_display_name(summoning_familiars[i]) + "!"
        dialog_message += " Go!"
        battle_dialog.open_and_wait(dialog_message, get_parent().BATTLE_DIALOG_WAIT_TIME)

func process(_delta):
    if not battle_dialog.is_open() and not tween.is_active():
        summon_familiars_and_switch_states()
    if Input.is_action_just_pressed("action"):
        battle_dialog.progress()

func handle_tween_finish():
    pass

func summon_familiars_and_switch_states():
    for i in range(0, 2):
        if i < director.player_party.get_living_familiar_count():
            summon_player_familiar(i)
    if get_parent().current_turn == -1:
        get_parent().set_state(State.CHOOSE_ACTION, {})
    else:
        get_parent().set_state(State.EVALUATE_MOVE, {})

func handle_timer_timeout():
    pass

func summon_player_familiar(i):
    player_sprites.get_child(i).texture = load(familiar_factory.get_portrait_path(director.player_party.familiars[i]))
    player_sprites.get_child(i).visible = true
    get_parent().update_player_label(i)
