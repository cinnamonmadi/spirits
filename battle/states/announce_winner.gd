extends Node
class_name AnnounceWinner

onready var director = get_node("/root/Director")

onready var success_log = get_parent().get_node("ui/success_log")
onready var success_log_label = get_parent().get_node("ui/success_log/label")
onready var timer = get_parent().get_node("timer")

const State = preload("res://battle/states/states.gd")

const SUCCESS_LOG_BASE_SIZE: int = 30
const SUCCESS_LOG_GROW_SIZE: int = 20
const SUCCESS_LOG_TICK_DURATION: float = 0.5

var requires_switch 
var switch_index
var success_log_messages = []

func begin(_params):
    # If there are any pending moves that would have involved using items, make sure to give the item back to the player
    for i in range(get_parent().current_turn + 1, get_parent().actions.size()):
        var action = get_parent().actions[i]
        if action.action == Action.USE_ITEM and action.who == "player":
            director.player_inventory.add_item(action.item, 1)

    success_log_messages = []

    # Determine the winner
    if director.player_party.get_living_familiar_count() == 0:
        handle_loss()
    else:
        handle_win()

    open_success_log()

func handle_win():
    success_log_messages.append("You win!")

    # If the player captured any monsters, add them to the crew!
    for i in range(0, get_parent().enemy_captured.size()):
        # TODO, change the < 6 rule to allow stoage familiars
        if get_parent().enemy_captured[i] and director.player_party.familiars.size() < 6:
            director.player_party.add_familiar(get_parent().enemy_party.familiars[i])
            success_log_messages.append("Wild " + get_parent().enemy_party.familiars[i].get_display_name() + " caught!")

    # Apply experience from defeated monsters
    var total_exp = 0
    for familiar in get_parent().enemy_party.familiars:
        total_exp += familiar.get_experience_yield()
    for i in range(0, director.player_party.familiars.size()):
        if not director.player_party.familiar_participated[i]:
            continue
        var familiar_old_level = director.player_party.familiars[i].level
        director.player_party.familiars[i].add_experience(total_exp)

        # If the familiar leveled up, add messages to the log
        var amount_of_level_ups = director.player_party.familiars[i].level - familiar_old_level
        for levelup_number in range(1, amount_of_level_ups + 1):
            success_log_messages.append(director.player_party.familiars[i].get_display_name() + " level " + String(familiar_old_level + levelup_number) + "!")

    director.player_party.recall_familiar_order()

func handle_loss():
    success_log_messages.append("You lose!")

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
    if Input.is_action_just_pressed("action"):
        if success_log_messages.size() != 0:
            success_log_pop_message()
            timer.stop()
            timer.start(SUCCESS_LOG_TICK_DURATION)
        else:
            end()
    
func handle_tween_finish():
    pass

func handle_timer_timeout():
    if success_log_messages.size() != 0:
        success_log_pop_message()
        timer.start(SUCCESS_LOG_TICK_DURATION)

func end():
    success_log.visible = false
    director.end_battle()
