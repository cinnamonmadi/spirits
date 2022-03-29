extends Node
class_name LearnMove

onready var director = get_node("/root/Director")

onready var dialog = get_parent().get_node("ui/dialog")
onready var dialog_yes_no = get_parent().get_node("ui/dialog_yes_no")
onready var forget_move_select = get_parent().get_node("ui/forget_move_select")

const State = preload("res://battle/states/states.gd")

enum SubState {
    PROMPT_REPLACE,
    REPLACE,
    ANNOUNCE_LEARN,
    ANNOUNCE_DIDNT_LEARN,
    CONFIRM_FORGET_MOVE,
    CONFIRM_GIVE_UP,
}

var familiar
var move
var substate 
var forget_move_index

func begin(params):
    familiar = params.familiar
    move = params.move

    var needs_replacing = familiar.moves.size() == 4
    if needs_replacing:
        set_state(SubState.PROMPT_REPLACE)
        substate = SubState.PROMPT_REPLACE
    else: 
        set_state(SubState.ANNOUNCE_LEARN)
        substate = SubState.ANNOUNCE_LEARN

func set_state(new_state):
    if substate == SubState.PROMPT_REPLACE or substate == SubState.CONFIRM_FORGET_MOVE or substate == SubState.CONFIRM_GIVE_UP:
        dialog_yes_no.close()
    elif substate == SubState.REPLACE:
        forget_move_select.close()

    substate = new_state

    if substate == SubState.PROMPT_REPLACE:
        dialog.open(familiar.get_display_name() + " is trying to learn " + familiar.get_move_name(move) + ", but " + familiar.get_display_name() + " already knows 4 moves. Should a move be forgotten and replaced with " + familiar.get_move_name(move) + "?")
    elif substate == SubState.ANNOUNCE_LEARN:
        dialog.open_with([[familiar.get_display_name() + " learned", familiar.get_move_name(move) + "!"]])
    elif substate == SubState.ANNOUNCE_DIDNT_LEARN:
        dialog.open_with([[familiar.get_display_name() + " did not learn", familiar.get_move_name(move) + "."]])
    elif substate == SubState.REPLACE:
        dialog.open("Which move should be forgotten?")
        forget_move_select.open()
        forget_move_select.set_labels([familiar.get_move_names()])
    elif substate == SubState.CONFIRM_FORGET_MOVE:
        dialog.open_with([["Forget " + familiar.get_move_names()[forget_move_index], "and learn " + familiar.get_move_name(move) + "?"]])
    elif substate == SubState.CONFIRM_GIVE_UP:
        dialog.open_with([["Give up on learning", familiar.get_move_name(move) + "?"]])

func process(_delta):
    var dialog_is_finished = dialog.is_waiting() and dialog.lines.size() == 0
    if not dialog_is_finished:
        if Input.is_action_just_pressed("action"):
            dialog.progress()
        return

    if substate == SubState.PROMPT_REPLACE:
        if not dialog_yes_no.visible:
            dialog_yes_no.open()
        var action = dialog_yes_no.check_for_input()
        if action == "Yes":
            set_state(SubState.REPLACE)
        elif action == "No":
            set_state(SubState.CONFIRM_GIVE_UP)
    elif substate == SubState.ANNOUNCE_DIDNT_LEARN or substate == SubState.ANNOUNCE_LEARN:
        if dialog.is_waiting() and Input.is_action_just_pressed("action"):
            exit_state()
    elif substate == SubState.REPLACE:
        if Input.is_action_just_pressed("back"):
            set_state(SubState.CONFIRM_GIVE_UP)
            return
        var chosen_move = forget_move_select.check_for_input()
        if chosen_move != "":
            forget_move_index = forget_move_select.cursor_position.y
            set_state(SubState.CONFIRM_FORGET_MOVE)
    elif substate == SubState.CONFIRM_FORGET_MOVE:
        if not dialog_yes_no.visible:
            dialog_yes_no.open()
        var action = dialog_yes_no.check_for_input()
        if action == "Yes":
            replace_move()
            set_state(SubState.ANNOUNCE_LEARN)
        elif action == "No":
            set_state(SubState.PROMPT_REPLACE)
    elif substate == SubState.CONFIRM_GIVE_UP:
        if not dialog_yes_no.visible:
            dialog_yes_no.open()
        var action = dialog_yes_no.check_for_input()
        if action == "Yes":
            set_state(SubState.ANNOUNCE_DIDNT_LEARN)
        elif action == "No":
            set_state(SubState.PROMPT_REPLACE)

func replace_move():
    familiar.moves[forget_move_index] = move
    
func handle_tween_finish():
    pass

func handle_timer_timeout():
    pass

func exit_state():
    dialog.close()
    dialog_yes_no.close()
    forget_move_select.close()
    get_parent().set_state(State.ANNOUNCE_WINNER, { "first_time_entering_state": false })
