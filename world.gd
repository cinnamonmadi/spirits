extends Node2D

onready var director = get_node("/root/Director")

onready var pause_menu = $ui/pause_menu
onready var party_menu = $ui/party_menu
onready var timer = $timer

enum State {
    WORLD,
    PAUSE_MENU,
    PARTY_MENU,
    ITEM_MENU,
}

var state = State.WORLD
var attacking_monster
var attacking_player_effect
var attack_surprise_round

func _ready():
    timer.connect("timeout", self, "_on_timer_timeout")
    pause_menu.close()

func set_paused(value):
    for pausable in get_tree().get_nodes_in_group("pausables"):
        pausable.paused = value

func set_state(new_state):
    if state == State.PAUSE_MENU:
        pause_menu.close()
    elif state == State.PARTY_MENU:
        party_menu.close()
    elif state == State.ITEM_MENU:
        party_menu.close()

    state = new_state

    if state == State.WORLD:
        set_paused(false)
    elif state == State.PAUSE_MENU:
        set_paused(true)
        pause_menu.open()
    elif state == State.PARTY_MENU:
        party_menu.open(false, false)
    elif state == State.ITEM_MENU:
        party_menu.open(false, true)

func _process(delta):
    if state == State.WORLD and Input.is_action_just_pressed("menu"):
        set_state(State.PAUSE_MENU)
    elif state == State.PAUSE_MENU:
        var action = pause_menu.check_for_input()
        if action == "EXIT" or Input.is_action_just_pressed("back"):
            set_state(State.WORLD)
        elif action == "SPIRITS":
            set_state(State.PARTY_MENU)
        elif action == "ITEM":
            set_state(State.ITEM_MENU)
    elif state == State.PARTY_MENU:
        party_menu.handle_process(delta)
        if party_menu.is_closed():
            set_state(State.PAUSE_MENU)
    elif state == State.ITEM_MENU:
        party_menu.handle_process(delta)
        if party_menu.is_closed():
            set_state(State.PAUSE_MENU)

func init_start_battle(monster, player_effect):
    for child in get_children():
        if "visible" in child:
            child.visible = false
    get_node("tris").visible = true
    monster.visible = true
    attacking_monster = monster

    if player_effect != null:
        player_effect.visible = true
        attacking_player_effect = player_effect

    set_paused(true)
    timer.start(1.0)

func _on_timer_timeout():
    attacking_monster.queue_free()
    if attacking_player_effect != null:
        attacking_player_effect.queue_free()
    director.start_battle()

func end_battle():
    for child in get_children():
        if "visible" in child:
            child.visible = true
    set_paused(false)
