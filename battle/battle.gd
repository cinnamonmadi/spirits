extends Node2D

onready var director = get_node("/root/Director")

onready var witch = $witch
onready var enemy_sprites = $enemy_sprites
onready var player_sprites = $player_sprites
onready var enemy_labels = $enemy_labels
onready var player_labels = $player_labels

onready var battle_actions = $ui/battle_actions
onready var move_select = $ui/move_select
onready var move_info = $ui/move_info
onready var party_menu = $ui/party_menu

onready var tween = $tween
onready var timer = $timer

const SCREEN_WIDTH: int = 640
const SPRITES_ENTERING_DURATION: float = 1.0

enum State {
    SPRITES_ENTERING,
    CHOOSE_ACTION,
}

var state = State.SPRITES_ENTERING
var enemy_familiars = []

func _ready():
    tween.connect("tween_all_completed", self, "_on_tween_finish")

    enemy_familiars.append(Familiar.new("SPHYNX", 3))

    close_all_menus()
    begin_sprites_entering()

func close_all_menus():
    battle_actions.close()
    move_select.close()
    move_info.close()
    party_menu.close()

func _on_tween_finish():
    if state == State.SPRITES_ENTERING:
        summon_player_familiars()
        begin_choose_action()

func _process(_delta):
    if state == State.CHOOSE_ACTION:
        process_choose_action()

func begin_sprites_entering():
    # Setup the enemy familiar sprites
    for i in range(0, 4):
        if i < enemy_familiars.size():
            enemy_sprites.get_child(3 - i).texture = load(enemy_familiars[i].get_portrait_path())
            enemy_sprites.get_child(3 - i).visible = true
    # Set the sprites in their initial positions to enter from
    tween.interpolate_property(enemy_sprites, "rect_position", 
                                Vector2(-enemy_sprites.rect_size.x, enemy_sprites.rect_position.y), 
                                Vector2(enemy_sprites.rect_position.x, enemy_sprites.rect_position.y), 
                                SPRITES_ENTERING_DURATION)
    tween.interpolate_property(witch, "rect_position", 
                                Vector2(SCREEN_WIDTH, witch.rect_position.y), 
                                Vector2(witch.rect_position.x, witch.rect_position.y), 
                                SPRITES_ENTERING_DURATION)
    # Begin the interpolation
    tween.start()
    state = State.SPRITES_ENTERING

func summon_player_familiars():
    for i in range(0, 2):
        if i < director.player_familiars.size():
            summon_player_familiar(i)

func summon_player_familiar(i):
    player_sprites.get_child(i).texture = load(director.player_familiars[i].get_portrait_path())
    player_sprites.get_child(i).visible = true
    set_player_label(i)

func set_player_label(i):
    player_labels.get_child(i).text = director.player_familiars[i].get_display_name()
    player_labels.get_child(i).get_child(0).text = "HP " + String(director.player_familiars[i].health) + " MP " + String(director.player_familiars[i].mana)
    player_labels.get_child(i).visible = true

func begin_choose_action():
    battle_actions.open()
    state = State.CHOOSE_ACTION

func process_choose_action():
    var _action = battle_actions.check_for_input()
