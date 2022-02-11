extends Node2D

onready var director = get_node("/root/Director")

onready var pause_menu = $pause_menu
onready var party_menu = $party_menu

enum State {
    WORLD,
    PAUSE_MENU,
    PARTY_MENU,
}

var state = State.WORLD
var transition_instance = null

func _ready():
    pause_menu.close()

func set_paused(value):
    for pausable in get_tree().get_nodes_in_group("pausables"):
        pausable.paused = value

func set_state(new_state):
    if state == State.PAUSE_MENU:
        pause_menu.close()
    elif state == State.PARTY_MENU:
        party_menu.close()

    state = new_state

    if state == State.WORLD:
        set_paused(false)
    elif state == State.PAUSE_MENU:
        set_paused(true)
        pause_menu.open()
    elif state == State.PARTY_MENU:
        party_menu.open()

func _process(_delta):
    if state == State.WORLD and Input.is_action_just_pressed("menu"):
        set_state(State.PAUSE_MENU)
    elif state == State.PAUSE_MENU:
        var action = pause_menu.check_for_input()
        if action == "EXIT" or Input.is_action_just_pressed("back"):
            set_state(State.WORLD)
        elif action == "SPIRITS":
            set_state(State.PARTY_MENU)
    elif state == State.PARTY_MENU:
        party_menu.check_for_input()
        if party_menu.is_closed():
            set_state(State.PAUSE_MENU)

func init_start_battle():
    director.start_battle()
