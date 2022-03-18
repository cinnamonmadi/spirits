extends Node
class_name AnnounceWinner

onready var director = get_node("/root/Director")

const State = preload("res://battle/states/states.gd")

var requires_switch 
var switch_index

func begin():
    # If there are any pending moves that would have involved using items, make sure to give the item back to the player
    for i in range(get_parent().current_turn + 1, get_parent().actions.size()):
        var action = get_parent().actions[i]
        if action.action == Action.USE_ITEM and action.who == "player":
            director.player_inventory.add_item(action.item, 1)

    # If the player captured any monsters, add them to the crew!
    for i in range(0, get_parent().enemy_captured.size()):
        # TODO, change the < 6 rule to allow stoage familiars
        if get_parent().enemy_captured[i] and director.player_party.familiars.size() < 6:
            director.player_party.familiars.append(get_parent().enemy_party.familiars[i])

    if director.player_party.get_living_familiar_count() == 0:
        get_parent().open_move_callout("You lose!")
    else:
        get_parent().open_move_callout("You win!")

func process(_delta):
    if Input.is_action_just_pressed("action"):
        director.end_battle()
    
func handle_tween_finish():
    pass
