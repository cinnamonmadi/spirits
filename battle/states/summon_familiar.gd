extends Node
class_name SummonFamiliar

onready var director = get_node("/root/Director")
onready var player_sprites = get_parent().get_node("player_sprites")
onready var player_labels = get_parent().get_node("player_labels")

const State = preload("res://battle/states/states.gd")

func begin():
    for i in range(0, 2):
        if i < director.player_party.get_living_familiar_count():
            summon_player_familiar(i)
    get_parent().set_state(State.CHOOSE_ACTION)

func process(_delta):
    return

func handle_tween_finish():
    return

func summon_player_familiar(i):
    player_sprites.get_child(i).texture = load(director.player_party.familiars[i].get_portrait_path())
    player_sprites.get_child(i).visible = true
    get_parent().update_player_label(i)
