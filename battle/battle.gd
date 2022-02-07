extends Node2D

# onready var familiar = preload("res://battle/familiar.gd")

onready var enemy_health = $enemy_health
onready var enemy_name_label = $enemy_health/label_name
onready var enemy_health_label = $enemy_health/label_health
onready var enemy_mana_label = $enemy_health/label_mana

onready var player_health = $player_health
onready var player_name_label = $player_health/label_name
onready var player_health_label = $player_health/label_health
onready var player_mana_label = $player_health/label_mana

onready var enemy_sprite = $familiar_enemy
onready var player_sprite = $familiar_player

onready var dialog = $dialog

enum State {
    INTRO_SPRITES_ENTERING,
    INTRO_ANNOUNCE_OPPONENT,
    INTRO_CALLOUT_FAMILIAR,
    INTRO_SUMMON_FAMILIAR,
    BATTLE_CHOOSE_ACTION,
    BATTLE_CHOOSE_MOVE,
    BATTLE_COMMENCE_MOVES,
    END_ANNOUNCE_WINNER
}

var state = State.INTRO_SPRITES_ENTERING
var enemy_familiar
var player_familiar
var timer: float

const SCREEN_WIDTH = 160

# Intro sprites entering
const SPRITE_ENTER_DURATION: float = 1.5
var player_sprite_start_x: int
var player_sprite_x: int
var enemy_sprite_start_x: int
var enemy_sprite_x: int

func _ready():
    dialog.keep_open = true
    dialog.DIALOG_SPEED = (1.0 / 60)
    dialog.open_empty()

    enemy_familiar = Familiar.new()
    enemy_familiar.family_name = "SPHYNX"
    player_familiar = Familiar.new()
    player_familiar.family_name = "SPHYNX"

    setup()

func setup():
    enemy_sprite.texture = load(enemy_familiar.get_portrait_path())
    enemy_name_label.text = enemy_familiar.family_name

    player_sprite.texture = load(player_familiar.get_portrait_path())
    player_name_label.text = player_familiar.family_name

    set_state(State.INTRO_SPRITES_ENTERING)

func set_state(new_state):
    state = new_state
    if state == State.INTRO_SPRITES_ENTERING:
        player_sprite.visible = false
        enemy_health.visible = false
        player_health.visible = false

        player_sprite_x = player_sprite.position.x
        player_sprite_start_x = SCREEN_WIDTH + (player_sprite.texture.get_size().x / 2)
        enemy_sprite_x = enemy_sprite.position.x
        enemy_sprite_start_x = -(enemy_sprite.texture.get_size().x / 2)

        timer = SPRITE_ENTER_DURATION
    elif state == State.INTRO_ANNOUNCE_OPPONENT:
        dialog.open("A wild " + enemy_familiar.family_name + " appeared!")
    elif state == State.INTRO_CALLOUT_FAMILIAR:
        enemy_health.visible = true
        dialog.open("Go! " + player_familiar.family_name + "!")
    elif state == State.INTRO_SUMMON_FAMILIAR:
        timer = 1.0
    elif state == State.BATTLE_CHOOSE_ACTION:
        dialog.open_empty()

func _process(delta):
    if state == State.INTRO_SPRITES_ENTERING:
        timer -= delta
        if timer <= 0:
            enemy_sprite.position.x = enemy_sprite_x
            player_sprite.position.x = player_sprite_x
            set_state(State.INTRO_ANNOUNCE_OPPONENT)
        else:
            enemy_sprite.position.x = enemy_sprite_start_x + ((enemy_sprite_x - enemy_sprite_start_x) * (1 - (timer / SPRITE_ENTER_DURATION)))
            player_sprite.position.x = player_sprite_start_x - ((player_sprite_start_x - player_sprite_x) * (1 - (timer / SPRITE_ENTER_DURATION)))
    elif state == State.INTRO_ANNOUNCE_OPPONENT:
        if dialog.is_waiting() and Input.is_action_just_pressed("action"):
            set_state(State.INTRO_CALLOUT_FAMILIAR)
    elif state == State.INTRO_CALLOUT_FAMILIAR:
        if dialog.is_waiting():
            set_state(State.INTRO_SUMMON_FAMILIAR)
    elif state == State.INTRO_SUMMON_FAMILIAR:
        timer -= delta
        if timer <= 0:
            player_sprite.visible = true
            player_health.visible = true
            set_state(State.BATTLE_CHOOSE_ACTION)
