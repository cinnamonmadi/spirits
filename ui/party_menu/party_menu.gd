extends ColorRect

onready var director = get_node("/root/Director")

onready var list = $choice_menu
onready var list_choices = $choice_menu/choices/col_1.get_children()
onready var select_menu = $select_menu
onready var summary = $summary
onready var switch_cursor = $switch_cursor

enum State {
    CLOSED,
    LIST,
    SELECTED,
    SUMMARY,
    SWITCH
}

var state = State.LIST
var chosen_index: int = -1
# Battle mode determines how the menu behaves in a fight. 
# It's almost exactly the same, except that the SWITCH command will always swap out your current
# fighter and then close the menu, rather than serving as a way to rearrange the list
var battle_mode: bool = false 
var battle_switch_index: int = -1
var battle_restricted_switch_indeces = []

# Switch variables
const SWITCH_CURSOR_FLICKER_DURATION: float = 0.3
var switch_cursor_timer: float

func _ready():
    close()

func is_closed():
    return state == State.CLOSED

func open(in_battle_mode: bool):
    battle_mode = in_battle_mode
    battle_switch_index = -1
    set_state(State.LIST)

func close():
    set_state(State.CLOSED)

func open_list():
    for choice in list_choices:
        choice.visible = false
    for i in range(0, director.player_party.familiars.size()):
        list_choices[i].text = director.player_party.familiars[i].get_display_name()
        list_choices[i].find_node("level").text = "LVL " + String(director.player_party.familiars[i].level)
        list_choices[i].find_node("health").text = "HP:" + String(director.player_party.familiars[i].health) + "/" + String(director.player_party.familiars[i].max_health) + " MP:" + String(director.player_party.familiars[i].mana) + "/" + String(director.player_party.familiars[i].max_mana)
        list_choices[i].visible = true
    list.reset_choices()
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
    switch_cursor.visible = false

    state = new_state

    if state == State.CLOSED:
        close_list()
        visible = false
    elif state == State.LIST:
        open_list()
    elif state == State.SELECTED:
        select_menu.open()
        # Don't show the switch option for the restricted indexes if in battle
        if battle_mode and battle_restricted_switch_indeces.has(chosen_index):
            select_menu.choices[0][1].visible = false
            select_menu.reset_choices()
        else:
            select_menu.choices[0][1].visible = true
            select_menu.reset_choices()
    elif state == State.SUMMARY:
        close_list()
        open_summary()
    elif state == State.SWITCH:
        switch_cursor.position = list.cursor.position
        switch_cursor.visible = true
        switch_cursor_timer = SWITCH_CURSOR_FLICKER_DURATION

func open_summary():
    var familiar = director.player_party.familiars[chosen_index]

    summary.get_node("name").text = familiar.get_display_name()
    summary.get_node("level").text = "LVL " + String(familiar.level)
    summary.get_node("type").text = familiar.types[0]
    summary.get_node("health").text = "HP " + String(familiar.health) + "/" + String(familiar.max_health)
    summary.get_node("mana").text = "MP " + String(familiar.mana) + "/" + String(familiar.max_mana)
    summary.get_node("attack").text = "ATTACK " + String(familiar.attack)
    summary.get_node("defense").text = "DEFENSE " + String(familiar.defense)
    summary.get_node("speed").text = "SPEED " + String(familiar.speed)
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
            if battle_mode:
                battle_switch_index = chosen_index
                close()
            else:
                set_state(State.SWITCH)
    elif state == State.SUMMARY:
        if Input.is_action_just_pressed("back"):
            set_state(State.LIST)
            return
        elif Input.is_action_just_pressed("right"):
            chosen_index = (chosen_index + 1) % director.player_party.familiars.size()
            set_state(State.SUMMARY)
        elif Input.is_action_just_pressed("left"):
            chosen_index -= 1
            if chosen_index == -1:
                chosen_index = director.player_party.familiars.size() - 1
            set_state(State.SUMMARY)
    elif state == State.SWITCH:
        if Input.is_action_just_pressed("back"):
            set_state(State.LIST)
            return
        var action = list.check_for_input()
        if action == "":
            return
        var switch_with_index = list.cursor_position.y
        if chosen_index != switch_with_index:
            director.player_party.swap_familiars(chosen_index, switch_with_index)
        set_state(State.LIST)

func _process(delta):
    if state == State.SWITCH:
        switch_cursor_timer -= delta
        if switch_cursor_timer <= 0:
            switch_cursor.visible = not switch_cursor.visible
            switch_cursor_timer = SWITCH_CURSOR_FLICKER_DURATION
