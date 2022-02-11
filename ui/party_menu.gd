extends ColorRect

onready var director = get_node("/root/Director")

onready var list = $choice_menu
onready var list_choices = $choice_menu/choices/col_1.get_children()
onready var select_menu = $select_menu
onready var summary = $summary

enum State {
    CLOSED,
    LIST,
    SELECTED,
    SUMMARY,
    SWITCH
}

var state = State.LIST
var chosen_index: int = -1

func _ready():
    set_state(State.CLOSED)

func is_closed():
    return state == State.CLOSED

func open():
    set_state(State.LIST)

func open_list():
    for choice in list_choices:
        choice.visible = false
    for i in range(0, director.player_familiars.size()):
        list_choices[i].text = director.player_familiars[i].get_display_name()
        list_choices[i].find_node("level").text = "LVL " + String(director.player_familiars[i].level)
        list_choices[i].find_node("health").text = "HP:" + String(director.player_familiars[i].health) + "/" + String(director.player_familiars[i].max_health) + " MP:" + String(director.player_familiars[i].mana) + "/" + String(director.player_familiars[i].max_mana)
        list_choices[i].visible = true
    list.reset()
    list.open()

func close_list():
    for choice in list_choices:
        choice.text = ""
        choice.visible = false
    list.close()

func set_state(new_state):
    visible = true

    summary.visible = false
    select_menu.close()

    state = new_state

    if state == State.CLOSED:
        close_list()
        visible = false
    elif state == State.LIST:
        open_list()
    elif state == State.SELECTED:
        select_menu.open()
    elif state == State.SUMMARY:
        close_list()
        open_summary()

func open_summary():
    var familiar = director.player_familiars[chosen_index]

    summary.get_node("name").text = familiar.get_display_name()
    summary.get_node("level").text = "LVL " + String(familiar.level)
    summary.get_node("type").text = familiar.type
    summary.get_node("health").text = "HP " + String(familiar.health) + "/" + String(familiar.max_health)
    summary.get_node("mana").text = "MP " + String(familiar.mana) + "/" + String(familiar.max_mana)
    summary.get_node("attack").text = "ATTACK " + String(familiar.attack)
    summary.get_node("defense").text = "DEFENSE " + String(familiar.defense)
    summary.get_node("speed").text = "SPEED " + String(familiar.speed)
    summary.get_node("focus").text = "FOCUS " + String(familiar.focus)
    for i in range(0, 4):
        var move_label = summary.get_node("move_" + String(i + 1))
        if i >= familiar.moves.size():
            move_label.visible = false
            continue
        var move_info = Familiar.MOVE_INFO[familiar.moves[i]]
        move_label.text = familiar.moves[i] + " / " + move_info["type"]
        move_label.get_node("details").text = "POWER " + String(move_info["power"]) + " COST " + String(move_info["cost"]) + "MP"
        move_label.visible = true

    summary.get_node("sprite").texture = load(familiar.get_portrait_path())

    summary.visible = true

func check_for_input():
    if state == State.LIST:
        if Input.is_action_just_pressed("back"):
            set_state(State.CLOSED)
            return
        var action = list.check_for_input()
        if action == "":
            return
        chosen_index = list.cursor_position.y
        set_state(State.SELECTED)
    elif state == State.SELECTED:
        if Input.is_action_just_pressed("back"):
            set_state(State.LIST)
            return
        var action = select_menu.check_for_input()
        if action == "SUMMARY":
            set_state(State.SUMMARY)
        elif action == "SWITCH":
            set_state(State.SWITCH)
    elif state == State.SUMMARY:
        if Input.is_action_just_pressed("back"):
            set_state(State.LIST)
            return
        elif Input.is_action_just_pressed("right"):
            chosen_index = (chosen_index + 1) % director.player_familiars.size()
            set_state(State.SUMMARY)
        elif Input.is_action_just_pressed("left"):
            chosen_index -= 1
            if chosen_index == -1:
                chosen_index = director.player_familiars.size() - 1
            set_state(State.SUMMARY)
