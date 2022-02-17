extends Node
class_name AnnounceWinner

onready var director = get_node("/root/Director")

const State = preload("res://battle/states/states.gd")

var requires_switch 
var switch_index

func begin():
    if director.player_party.get_living_familiar_count() == 0:
        get_parent().open_move_callout("You lose!")
    else:
        get_parent().open_move_callout("You win!")

func process(_delta):
    if Input.is_action_just_pressed("action"):
        pass
        # end battle
    
func handle_tween_finish():
    pass
