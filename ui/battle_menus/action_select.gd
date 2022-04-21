extends Control

onready var familiar_factory = get_node("/root/FamiliarFactory")

onready var action_boxes = [[$move_1, $move_2, $switch, $run], [$move_3, $move_4, $wait, $item]]
onready var move_boxes = [$move_1, $move_2, $move_3, $move_4]
onready var move_info_box = $move_info

const CURSOR_POSITION_SWITCH = Vector2(2, 0)
const CURSOR_POSITION_RUN = Vector2(3, 0)
const CURSOR_POSITION_WAIT = Vector2(2, 1)
const CURSOR_POSITION_ITEM = Vector2(3, 1)

var cursor_position: Vector2
var move_info = []

func _ready():
    pass 

func open(moves):
    move_info = []
    for i in range(0, 4):
        if i < moves.size():
            move_info.append(familiar_factory.get_stringified_move_info(moves[i], 28))
            move_boxes[i].get_child(0).text = familiar_factory.get_move_name(moves[i])
        else:
            move_info.append(null)
            move_boxes[i].get_child(0).text = ""

    reset_cursor_position()
    visible = true

func close():
    visible = false
    action_boxes[cursor_position.y][cursor_position.x].get_child(0).set("custom_colors/font_color", Color(1, 1, 1, 1))

func get_selected_move_index() -> int:
    if cursor_position.x > 1:
        return -1
    else:
        return int(cursor_position.x) + int(cursor_position.y * 2)

# Cursor is valid if it is in bounds and if it is selected a non-empty move
func is_cursor_position_valid() -> bool:
    if cursor_position.x < 0 or cursor_position.x >= 4:
        return false
    if cursor_position.y < 0 or cursor_position.y >= 2:
        return false
    var selected_move_index = get_selected_move_index()
    if selected_move_index != -1 and move_info[selected_move_index] == null:
        return false
    return true

func reset_cursor_position():
    for action_box in action_boxes[0]:
        action_box.get_child(0).set("custom_colors/font_color", Color(1, 1, 1, 1))
    for action_box in action_boxes[1]:
        action_box.get_child(0).set("custom_colors/font_color", Color(1, 1, 1, 1))
    cursor_position = Vector2.ZERO
    action_boxes[cursor_position.y][cursor_position.x].get_child(0).set("custom_colors/font_color", Color(1, 1, 0, 1))
    update_move_info_box()

func navigate(direction: Vector2):
    # De-highlight the current action label
    action_boxes[cursor_position.y][cursor_position.x].get_child(0).set("custom_colors/font_color", Color(1, 1, 1, 1))

    # Increment the cursor
    cursor_position += direction
    while not is_cursor_position_valid():
        # If out of bounds, wrap cursor arond
        if cursor_position.x < 0:
            cursor_position.x = 3
        elif cursor_position.x >= 4:
            cursor_position.x = 0
        elif cursor_position.y < 0:
            cursor_position.y = 1
        elif cursor_position.y >= 2:
            cursor_position.y = 0
        # If cursor_position is invalid and is within bounds, then cursor_position is on an empty move,
        # so step the cursor in the direction until we land on a valid option
        else:
            cursor_position += direction

    # Highlight the new action label
    action_boxes[cursor_position.y][cursor_position.x].get_child(0).set("custom_colors/font_color", Color(1, 1, 0, 1))
    update_move_info_box()

func update_move_info_box():
    var selected_move = get_selected_move_index()
    var move_info_lines  
    if selected_move != -1:
        move_info_lines = move_info[selected_move]
    elif cursor_position == CURSOR_POSITION_SWITCH:
        move_info_lines = ["SWITCH", "Switch current fighter with", "another spirit"]
    elif cursor_position == CURSOR_POSITION_RUN:
        move_info_lines = ["RUN", "Attempt to escape from", "battle"]
    elif cursor_position == CURSOR_POSITION_WAIT:
        move_info_lines = ["WAIT", "Do nothing and allow this", "spirit to recover energy"]
    elif cursor_position == CURSOR_POSITION_ITEM:
        move_info_lines = ["ITEM", "Use an item from your", "inventory"]

    for i in range(0, move_info_box.get_child_count()):
        move_info_box.get_child(i).text = move_info_lines[i]
    
