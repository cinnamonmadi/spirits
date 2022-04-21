extends Node
class_name AnnounceWinner

onready var director = get_node("/root/Director")
onready var familiar_factory = get_node("/root/FamiliarFactory")

onready var dialog = get_parent().get_node("ui/dialog")
onready var player_labels = get_parent().get_node("player_labels")

const State = preload("res://battle/states/states.gd")

enum SubState {
    GIVE_EXP,
}

const SUCCESS_LOG_BASE_SIZE: int = 30
const SUCCESS_LOG_GROW_SIZE: int = 20
const SUCCESS_LOG_TICK_DURATION: float = 0.5

var requires_switch 
var switch_index
var success_log_messages = []
var player_won
var todos = []
var participating_player_familiars = []
var exp_to_give = []
var substate = SubState.GIVE_EXP

func begin(params):
    if not params.first_time_entering_state:
        handle_todos()
        return

    # If there are any pending moves that would have involved using items, make sure to give the item back to the player
    for i in range(get_parent().current_turn + 1, get_parent().actions.size()):
        var action = get_parent().actions[i]
        if action.action == Action.USE_ITEM and action.who == "player":
            director.player_inventory.add_item(action.item, 1)

    success_log_messages = []

    # Determine the winner
    player_won = director.player_party.get_living_familiar_count() != 0
    if player_won:
        handle_win()
    else:
        handle_loss()

func handle_todos():
    if todos.size() == 0:
        end()
        return

    var next_todo = todos.pop_front()

    if next_todo.type == "capture":
        get_parent().set_state(State.NAME_FAMILIAR, { "familiar": next_todo.familiar })
    elif next_todo.type == "learn_move":
        get_parent().set_state(State.LEARN_MOVE, { "familiar": next_todo.familiar, "move": next_todo.move })

func handle_win():
    todos = []

    # Count experience from defeated monsters
    var total_exp = 0
    for familiar in get_parent().enemy_party.familiars:
        total_exp += familiar.get_experience_yield()
        
    dialog.open("Gained " + String(total_exp) + " experience!")

    # Get the list of participating player familiar indexes
    participating_player_familiars = []
    for i in range(0, director.player_party.familiars.size()):
        exp_to_give.append(0)
        if director.player_party.familiar_participated[i] and director.player_party.familiars[i].is_living():
            participating_player_familiars.append(i)
    
    # Divide the experience between familiars
    var exp_per_familiar = int(total_exp / participating_player_familiars.size())

    for i in range(0, participating_player_familiars.size()):
        # Determine how much exp to give
        # If the exp doesn't divide evenly, give the odd experience points to the first one on the list
        var participating_familiar_index = participating_player_familiars[i]
        exp_to_give[participating_familiar_index] = exp_per_familiar
        if i == 0:
            exp_to_give[participating_familiar_index] += exp_per_familiar % participating_player_familiars.size()

    # If the player captured any monsters, add them to the crew!
    for i in range(0, get_parent().enemy_captured.size()):
        # TODO, change the < 6 rule to allow stoage familiars
        if get_parent().enemy_captured[i] and director.player_party.familiars.size() < 6:
            director.player_party.add_familiar(get_parent().enemy_party.familiars[i])
            todos.append({ "type": "capture", "familiar": get_parent().enemy_party.familiars[i] })

func handle_loss():
    dialog.open_with("All spirits were defeated! You lose!")

func process(_delta):
    if dialog.is_open():
        if Input.is_action_just_pressed("action"):
            dialog.progress()
        return
    if not player_won:
        director.player_party.recall_familiar_order()
        end()
    else:
        var done_giving_exp = true
        for participating_familiar_index in participating_player_familiars:
            if exp_to_give[participating_familiar_index] != 0:
                done_giving_exp = false
                var familiar = director.player_party.familiars[participating_familiar_index]

                var familiar_old_level = familiar.get_level()
                exp_to_give[participating_familiar_index] -= 1
                familiar.add_experience(1)
                if familiar.get_level() != familiar_old_level:
                    dialog.open(familiar_factory.get_display_name(familiar) + " level " + String(familiar.get_level()) + "!")
                    var learned_moves = familiar.get_level_up_moves(familiar.get_level())
                    for learned_move in learned_moves:
                        todos.append({ "type": "learn_move", "familiar": familiar, "move": learned_move })
                    return
        if done_giving_exp:
            director.player_party.recall_familiar_order()
            handle_todos()
    
func handle_tween_finish():
    pass

func handle_timer_timeout():
    pass

func end():
    director.end_battle()
