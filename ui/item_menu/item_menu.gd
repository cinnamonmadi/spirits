extends ColorRect

onready var director = get_node("/root/Director")

onready var category_label = $category/label
onready var desc_name = $desc/name
onready var desc_row_1 = $desc/desc/one
onready var desc_row_2 = $desc/desc/two
onready var item_list = $item_list
onready var select = $select

enum State {
    CLOSED,
    LIST,
    SELECT,
    ORDER
}

const ITEM_LIST_HEIGHT = 14

var category = Inventory.Category.POTION
var list_offset = 0
var state = State.CLOSED

func _ready():
    select.close()
    open()

func is_closed():
    return state == State.CLOSED

func set_state(new_state):
    state = new_state
    if state == State.CLOSED:
        close()

func close():
    select.close()
    item_list.close()

func open():
    category = 0
    open_category()
    state = State.LIST

func _process(_delta):
    if state == State.LIST:
        process_list()

func process_list():
    if Input.is_action_just_pressed("back"):
        set_state(State.CLOSED)
        return
    if Input.is_action_just_pressed("right"):
        category = (category + 1) % Inventory.Category.keys().size()
        open_category()
    elif Input.is_action_just_pressed("left"):
        if category == 0:
            category = Inventory.Category.keys().size() - 1
        else:
            category -= 1
        open_category()
    elif Input.is_action_just_pressed("up"):
        item_list.cursor_position.y -= 1
        if item_list.cursor_position.y < 0:
            if director.player_inventory.size(category) < ITEM_LIST_HEIGHT:
                item_list.cursor_position.y = director.player_inventory.size(category) - 1
            else:
                if list_offset == 0:
                    list_offset = director.player_inventory.size(category) - ITEM_LIST_HEIGHT
                    item_list.cursor_position.y = ITEM_LIST_HEIGHT - 1
                else:
                    list_offset -= 1
                    item_list.cursor_position.y = 0
                refresh_items()
        update_description()
        item_list.set_cursor_position()
    elif Input.is_action_just_pressed("down"):
        item_list.cursor_position.y += 1
        if director.player_inventory.size(category) < ITEM_LIST_HEIGHT and item_list.cursor_position.y >= director.player_inventory.size(category):
            item_list.cursor_position.y = 0
        elif item_list.cursor_position.y >= ITEM_LIST_HEIGHT:
            if list_offset + ITEM_LIST_HEIGHT < director.player_inventory.size(category):
                item_list.cursor_position.y -= 1
                list_offset += 1
            else:
                item_list.cursor_position.y = 0
                list_offset = 0
            refresh_items()
        update_description()
        item_list.set_cursor_position()

func open_category():
    list_offset = 0

    print(Inventory.Category.keys())
    category_label.text = Inventory.Category.keys()[category]
    refresh_items()

func refresh_items():
    var list_values = []
    for i in range(0, ITEM_LIST_HEIGHT):
        var index = list_offset + i
        if director.player_inventory.size(category) <= index:
            list_values.append("")
        else:
            var item = director.player_inventory.item_name_at(category, index)
            print(item)
            var quantity = director.player_inventory.quantity_at(category, index)
            list_values.append(item + " x" + String(quantity))
    item_list.set_labels([list_values])
    item_list.reset_choices()
    item_list.open()
    update_description()

func update_description():
    if director.player_inventory.size(category) == 0:
        desc_name.text = ""
        desc_row_1.text = ""
        desc_row_2.text = ""
        return
    var index = list_offset + item_list.cursor_position.y
    desc_name.text = director.player_inventory.item_name_at(category, index) + " x" + String(director.player_inventory.quantity_at(category, index))

    var ROW_LENGTH = 20
    var desc = director.player_inventory.item_desc_at(category, index)
    var words = desc.split(" ")
    var desc_lines = ["", ""]
    var row = 0
    while words.size() != 0:
        var next_word = words[0]
        words.remove(0)

        # Add a space between words if needed
        if desc_lines[row].length() != 0:
            next_word = " " + next_word

        # Check if there's enough space to insert the word
        var space_left_in_row = ROW_LENGTH - desc_lines[row].length()
        if space_left_in_row < next_word.length():
            # Increment rows
            row += 1
            if row == 2:
                break
            # If we added a space before, remove it since we're going to the next line
            if next_word[0] ==  " ":
                next_word = next_word.substr(1)

        # Insert the word
        desc_lines[row] += next_word

    desc_row_1.text = desc_lines[0]
    desc_row_2.text = desc_lines[1]
