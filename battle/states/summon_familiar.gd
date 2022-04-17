extends Node
class_name SummonFamiliar

onready var director = get_node("/root/Director")
onready var familiar_factory = get_node("/root/FamiliarFactory")

onready var player_sprites = get_parent().get_node("player_sprites")
onready var tween = get_parent().get_node("tween")
onready var witch = get_parent().get_node("witch")
onready var move_callout = get_parent().get_node("ui/move_callout")

const WITCH_EXIT_DURATION: float = 1.0

const State = preload("res://battle/states/states.gd")

func begin(params):
    if params.trigger_witch_exit:
        tween.interpolate_property(witch, "position", witch.position, witch.position - Vector2(witch.texture.get_size().x, 0), WITCH_EXIT_DURATION)
        tween.start()
    else:
        handle_tween_finish()

func process(_delta):
    return

func handle_tween_finish():
    for i in range(0, 2):
        if i < director.player_party.get_living_familiar_count():
            summon_player_familiar(i)
    if get_parent().surprise_round != "none":
        move_callout.visible = false
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
