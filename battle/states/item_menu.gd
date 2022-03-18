extends Node
class_name ItemMenu

onready var director = get_node("/root/Director")

onready var party_menu = get_parent().get_node("ui/party_menu")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

var requires_switch 
var switch_index

func begin():
    party_menu.open(true, true)

func process(delta):
    # Check for input on the party menu
    party_menu.handle_process(delta)
    if party_menu.is_closed():
        var chosen_item = party_menu.item_used

        # If player didn't choose an item, do nothing
        if chosen_item == -1:
            get_parent().set_state(State.CHOOSE_ACTION)
            return

        # If player choose an item that targets enemies, open the choose target screen
        var chosen_item_info = Inventory.ITEM_INFO[chosen_item]
        if chosen_item_info.targets == Inventory.ItemTargets.ENEMIES:
            get_parent().chosen_item = chosen_item
            get_parent().targeting_for_action = Action.USE_ITEM
            get_parent().set_state(State.CHOOSE_TARGET)
        # Otherwise add the item use action to the actions list
        else:
            get_parent().actions.append({
                "who": "player",
                "familiar": get_parent().player_choosing_index,
                "action": Action.USE_ITEM,
                "item": party_menu.item_used,
                "target_who": "player",
                "target_familiar": party_menu.item_target
            })
            director.player_inventory.remove_item(party_menu.item_used, 1)
            get_parent().set_state(State.CHOOSE_ACTION)
    
func handle_tween_finish():
    pass
