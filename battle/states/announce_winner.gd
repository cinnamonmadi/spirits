extends Node
class_name AnnounceWinner

onready var director = get_node("/root/Director")

onready var success_log = get_parent().get_node("ui/success_log")
onready var success_log_label = get_parent().get_node("ui/success_log/label")
onready var timer = get_parent().get_node("timer")
onready var dialog = get_parent().get_node("ui/dialog")

const State = preload("res://battle/states/states.gd")

const SUCCESS_LOG_BASE_SIZE: int = 30
const SUCCESS_LOG_GROW_SIZE: int = 20
const SUCCESS_LOG_TICK_DURATION: float = 0.5

var requires_switch 
var switch_index
var success_log_messages = []
var player_won
var todos = []

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
        
    success_log_messages.append("Gained " + String(total_exp) + " experience!")

    # Get the list of participating player familiar indexes
    var participating_player_familiars = []
    for i in range(0, director.player_party.familiars.size()):
        if director.player_party.familiar_participated[i]:
            participating_player_familiars.append(i)
    
    # Divide the experience between familiars
    var exp_per_familiar = int(total_exp / participating_player_familiars.size())

    for i in range(0, participating_player_familiars.size()):
        # Determine how much exp to give
        # If the exp doesn't divide evenly, give the odd experience points to the first one on the list
        var exp_to_give = exp_per_familiar
        if i == 0:
            exp_to_give += exp_per_familiar % participating_player_familiars.size()

        var familiar_index = participating_player_familiars[i]
        var familiar_old_level = director.player_party.familiars[familiar_index].level
        director.player_party.familiars[i].add_experience(exp_to_give)

        # If the familiar leveled up, add messages to the log
        var amount_of_level_ups = director.player_party.familiars[familiar_index].level - familiar_old_level
        var learned_moves = []
        for levelup_number in range(1, amount_of_level_ups + 1):
            learned_moves += director.player_party.familiars[familiar_index].get_level_up_moves(familiar_old_level + levelup_number)
            success_log_messages.append(director.player_party.familiars[familiar_index].get_display_name() + " level " + String(familiar_old_level + levelup_number) + "!")

        for learned_move in learned_moves:
            todos.append({ "type": "learn_move", "familiar": director.player_party.familiars[familiar_index], "move": learned_move })

    # Return party order to how it was before the fight started
    director.player_party.recall_familiar_order()

    # If the player captured any monsters, add them to the crew!
    for i in range(0, get_parent().enemy_captured.size()):
        # TODO, change the < 6 rule to allow stoage familiars
        if get_parent().enemy_captured[i] and director.player_party.familiars.size() < 6:
            director.player_party.add_familiar(get_parent().enemy_party.familiars[i])
            todos.append({ "type": "capture", "familiar": get_parent().enemy_party.familiars[i] })

    open_success_log()

func handle_loss():
    dialog.open_with("All spirits were defeated! You lose!")

func open_success_log():
    success_log.rect_size.y = 30
    success_log.visible = true
    success_log_label.text = ""
    success_log_pop_message()
    timer.start(SUCCESS_LOG_TICK_DURATION)

func success_log_pop_message():
    if success_log_label.text != "":
        success_log_label.text += "\n"
        success_log.rect_size.y += SUCCESS_LOG_GROW_SIZE
    success_log_label.text += success_log_messages.pop_front()

func process(_delta):
    if not player_won:
        if Input.is_action_just_pressed("action"):
            if dialog.is_waiting():
                end()
            else:
                dialog.progress()
    else:
        if Input.is_action_just_pressed("action"):
            if success_log_messages.size() != 0:
                success_log_pop_message()
                timer.stop()
                timer.start(SUCCESS_LOG_TICK_DURATION)
            else:
                success_log.visible = false
                handle_todos()
    
func handle_tween_finish():
    pass

func handle_timer_timeout():
    if success_log_messages.size() != 0:
        success_log_pop_message()
        timer.start(SUCCESS_LOG_TICK_DURATION)

func end():
    director.end_battle()
