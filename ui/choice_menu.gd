extends NinePatchRect

onready var cursor = $cursor

const input_names = ["up", "right", "down", "left"]
const input_directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

var cursor_position = Vector2.ZERO # Uses a Vector2 in case there are columns as well as rows
var choices = [] # Will be a 2D array of all the option labels
var column_sizes = []
var num_columns = 0

var remember_cursor_position = false

func _ready():
    var choices_tree_item = $choices
    choices = []
    for column in choices_tree_item.get_children():
        var new_column = []
        for label in column.get_children():
            new_column.append(label)
        choices.append(new_column)
    reset_choices()

func reset_choices():
    column_sizes = []
    num_columns = 0
    for x in range(0, choices.size()):
        num_columns += 1
        column_sizes.append(0)
        for y in range(0, choices[x].size()):
            if not choices[x][y].visible:
                continue
            column_sizes[x] += 1
    set_cursor_position()

func set_labels(values):
    for x in range(0, values.size()):
        for y in range(0, values[x].size()):
            choices[x][y].text = values[x][y]

func open():
    visible = true

func close():
    if not remember_cursor_position:
        cursor_position = Vector2.ZERO
        set_cursor_position()
    visible = false

func set_cursor_position():
    cursor.position = choices[int(cursor_position.x)][int(cursor_position.y)].rect_position + Vector2(-10, 0)
    
# Input should be a single-direction unit vector, although I suppose the code should work even if it isn't
func navigate(input_direction: Vector2):
    cursor_position.x = int(cursor_position.x + input_direction.x) % num_columns
    cursor_position.y = int(cursor_position.y + input_direction.y) % column_sizes[cursor_position.x]
    set_cursor_position()

func select():
    return choices[int(cursor_position.x)][int(cursor_position.y)].text

func check_for_input():
    for i in range(0, 4):
        if Input.is_action_just_pressed(input_names[i]):
            navigate(input_directions[i])
    if Input.is_action_just_pressed("action"):
        return select()
    else:
        return ""
