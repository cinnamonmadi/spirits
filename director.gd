extends Node

const SCREEN_WIDTH: int = 160

var battle_scene = preload("res://battle/battle.tscn")
var transition_scene = preload("res://transition.tscn")

var world_instance
var battle_instance
var transition_instance

var pause_menu
var party_menu

var player_familiars = []

enum State {
    WORLD,
    PAUSE_MENU,
    PARTY_MENU,
    TRANSITION,
    BATTLE
}

var state = State.WORLD

func _ready():
    player_familiars.append(Familiar.new())
    player_familiars[0].species = "SPHYNX"
    player_familiars[0].health = 20
    player_familiars[0].max_health = 20
    player_familiars[0].mana = 10
    player_familiars[0].max_mana = 10
    player_familiars.append(Familiar.new())
    player_familiars[1].species = "OWLBEAR"
    player_familiars[1].health = 34
    player_familiars[1].max_health = 40
    player_familiars[1].mana = 5
    player_familiars[1].max_mana = 5

    var root = get_tree().get_root()
    world_instance = root.get_child(root.get_child_count() - 1)
    pause_mode = Node.PAUSE_MODE_PROCESS

    pause_menu = load("res://ui/pause_menu.tscn").instance()
    pause_menu.rect_position.x = SCREEN_WIDTH - pause_menu.rect_size.x
    pause_menu._ready()
    pause_menu.close()

    party_menu = load("res://ui/party_menu.tscn").instance()

    world_instance.add_child(pause_menu)
    world_instance.add_child(party_menu)

func _process(_delta):
    if state == State.TRANSITION and transition_instance.finished:
        var root = get_tree().get_root()
        
        transition_instance.free()
        root.remove_child(world_instance)

        battle_instance = battle_scene.instance()
        root.add_child(battle_instance)
        get_tree().paused = false
        state = State.BATTLE
    elif state == State.WORLD and Input.is_action_just_pressed("menu"):
        get_tree().paused = true
        pause_menu.open()
        state = State.PAUSE_MENU
    elif state == State.PAUSE_MENU:
        var action = pause_menu.check_for_input()
        if action == "EXIT" or Input.is_action_just_pressed("back"):
            pause_menu.close()
            get_tree().paused = false
            state = State.WORLD
        elif action == "SPIRITS":
            party_menu.open(player_familiars)
            state = State.PARTY_MENU
    elif state == State.PARTY_MENU:
        var _action = party_menu.check_for_input()
        if Input.is_action_just_pressed("back"):
            party_menu.close()
            state = State.PAUSE_MENU

func start_battle():
    get_tree().paused = true

    transition_instance = transition_scene.instance()
    transition_instance.pause_mode = Node.PAUSE_MODE_PROCESS
    world_instance.add_child(transition_instance)
    state = State.TRANSITION

func end_battle():
    var root = get_tree().get_root()
    battle_instance.free()
    root.add_child(world_instance)
    state = State.WORLD
