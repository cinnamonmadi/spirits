extends Node
class_name PartyMenu

onready var director = get_node("/root/Director")

onready var party_menu = get_parent().get_node("ui/party_menu")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

var requires_switch 
var switch_index

func begin(_params):
    requires_switch = get_parent().current_turn != -1
    if requires_switch:
        for i in range(0, 2):
            if not director.player_party.familiars[i].is_living():
                switch_index = i
                break
    else:
        switch_index = get_parent().get_choosing_familiar_index()
    party_menu.open(true, false)
    party_menu.battle_restricted_switch_indeces = [0, 1]
    # Don't allow player to switch to the same familiar with two different familiars
    if get_parent().actions.size() != 0 and get_parent().actions[0].action == Action.SWITCH:
        party_menu.battle_restricted_switch_indeces.append(get_parent().actions[0].with)

func process(delta):
    # Check for input on the party menu
    party_menu.handle_process(delta)
    if party_menu.is_closed():
        if requires_switch and party_menu.battle_switch_index == -1:
            party_menu.open(true)
        elif requires_switch and party_menu.battle_switch_index != -1:
            director.player_party.swap_familiars(switch_index, party_menu.battle_switch_index)
            get_parent().set_state(State.SUMMON_FAMILIARS, { "trigger_witch_exit": false })
        elif not requires_switch:
            if party_menu.battle_switch_index != -1:
                get_parent().actions.append({
                    "who": "player",
                    "familiar": switch_index,
                    "action": Action.SWITCH,
                    "with": party_menu.battle_switch_index
                })
            get_parent().set_state(State.CHOOSE_ACTION, {})
    
func handle_tween_finish():
    pass
