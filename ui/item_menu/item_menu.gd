extends ColorRect

onready var director = get_node("/root/Director")

onready var category_label = $category/label
onready var desc_name = $desc/name
onready var desc_row_1 = $desc/desc/one
onready var desc_row_2 = $desc/desc/two
onready var item_list = $item_list
onready var select = $select
onready var cursor = $item_list/cursor
onready var order_cursor = $item_list/order_cursor
onready var use_dialog = $use_dialog

enum State {
    CLOSED,
    LIST,
    SELECT,
    ORDER,
    CANT_USE,
}

const ITEM_LIST_HEIGHT = 14
const ORDER_CURSOR_TIMER_DURATION = 0.5

var category = Inventory.Category.POTION
var list_offset = 0
var order_cursor_timer = 0
var order_cursor_index = 0
var state = State.CLOSED
var battle_mode = false

func _ready():
    use_dialog.ROW_CHAR_LEN = 20
    select.close()

func is_closed():
    return state == State.CLOSED

func set_state(new_state):
    if state == State.SELECT:
        select.close()

    state = new_state

    if state == State.CLOSED:
        close()
    elif state == State.LIST:
        refresh_items()
    elif state == State.SELECT:
        select.open()
    elif state == State.ORDER:
        begin_order()
    elif state == State.CANT_USE:
        begin_cant_use()

func close():
    select.close()
    item_list.close()
    order_cursor.visible = false
    visible = false

func open(in_battle_mode):
    battle_mode = in_battle_mode
    category = 0
    open_category()
    state = State.LIST
    visible = true

func handle_process(delta):
    if state == State.LIST:
        process_list()
    elif state == State.SELECT:
        process_select()
    elif state == State.ORDER:
        process_order(delta)
    elif state == State.CANT_USE:
        process_cant_use()

func get_item_list_inventory_index():
    return list_offset + item_list.cursor_position.y

func list_navigate_up():
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
    item_list.set_cursor_position()

func list_navigate_down():
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
        list_navigate_up()
        update_description()
    elif Input.is_action_just_pressed("down"):
        list_navigate_down()
    elif Input.is_action_just_pressed("action"):
        if director.player_inventory.size(category) != 0:
            set_state(State.SELECT)

func open_category():
    list_offset = 0

    category_label.text = Inventory.Category.keys()[category]
    refresh_items()

func refresh_items():
    var list_values = []
    for i in range(0, ITEM_LIST_HEIGHT):
        var index = i + list_offset
        if director.player_inventory.size(category) <= index:
            list_values.append("")
        else:
            var item = director.player_inventory.item_name_at(category, index)
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

func process_select():
    var action = select.check_for_input()
    if Input.is_action_just_pressed("back"):
        set_state(State.LIST)
    elif action == "ORDER":
        set_state(State.ORDER)
    elif action == "USE":
        try_use_item()

func try_use_item():
    var item_use = director.player_inventory.item_use_at(category, get_item_list_inventory_index())
    if (battle_mode and item_use == Inventory.ItemUse.WORLD) or (not battle_mode and item_use == Inventory.ItemUse.BATTLE):
        set_state(State.CANT_USE)

func begin_order():
    order_cursor_index = item_list.cursor_position.y
    order_cursor_timer = ORDER_CURSOR_TIMER_DURATION
    set_order_cursor_position()

func set_order_cursor_position():
    if not order_cursor_index in range(list_offset, list_offset + ITEM_LIST_HEIGHT):
        order_cursor.position.y = -20
    else:
        order_cursor.position = item_list.choices[0][order_cursor_index].rect_position + Vector2(-10, 0)

func process_order(delta):
    set_order_cursor_position()
    order_cursor_timer -= delta
    if order_cursor_timer <= 0:
        order_cursor_timer = ORDER_CURSOR_TIMER_DURATION
        order_cursor.visible = not order_cursor.visible
    if Input.is_action_just_pressed("up"):
        list_navigate_up()
    elif Input.is_action_just_pressed("down"):
        list_navigate_down()
    elif Input.is_action_just_pressed("action"):
        director.player_inventory.swap_items(category, order_cursor_index, get_item_list_inventory_index())
        order_cursor.visible = false
        set_state(State.LIST)
    elif Input.is_action_just_pressed("back"):
        order_cursor.visible = false
        set_state(State.LIST)

func begin_cant_use():
    if battle_mode:
        use_dialog.open('This item can only be used in battle.')
    else:
        use_dialog.open('This item cannot be used in battle.')

func process_cant_use():
    if Input.is_action_just_pressed("action"):
        use_dialog.progress()
    if not use_dialog.is_open():
        set_state(State.SELECT)
