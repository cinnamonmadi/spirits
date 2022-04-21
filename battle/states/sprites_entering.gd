extends Node
class_name SpritesEntering

onready var familiar_factory = get_node("/root/FamiliarFactory")

onready var witch = get_parent().get_node("witch")
onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var tween = get_parent().get_node("tween")
onready var battle_dialog = get_parent().get_node("ui/battle_dialog")

const State = preload("res://battle/states/states.gd")

const SPRITES_ENTERING_DURATION: float = 1.0

func begin(_params):
    # Setup the enemy familiar sprites
    for i in range(0, get_parent().enemy_party.familiars.size()):
        enemy_sprites.get_child(1 - i).texture = load(familiar_factory.get_portrait_path(get_parent().enemy_party.familiars[i]))
        enemy_sprites.get_child(1 - i).visible = true

    # Set the sprites in their initial positions to enter from
    tween.interpolate_property(enemy_sprites, "rect_position", 
                                Vector2(-enemy_sprites.rect_size.x, enemy_sprites.rect_position.y), 
                                Vector2(enemy_sprites.rect_position.x, enemy_sprites.rect_position.y), 
                                SPRITES_ENTERING_DURATION)
    tween.interpolate_property(witch, "position", 
                                Vector2(get_parent().SCREEN_WIDTH, witch.position.y), 
                                witch.position, 
                                SPRITES_ENTERING_DURATION)
    # Begin the interpolation
    tween.start()

func process(_delta):
    if Input.is_action_just_pressed("action"):
        if battle_dialog.is_waiting():
            get_parent().set_state(State.SUMMON_FAMILIARS, { "trigger_witch_exit": true, "who": "player" })
        else:
            battle_dialog.progress()

func handle_tween_finish():
    for i in range(0, get_parent().enemy_party.familiars.size()):
        get_parent().update_enemy_label(i)
    
    # Create dialog message based on enemy names
    var enemy_fighters = []
    for i in range(0, min(2, get_parent().enemy_party.familiars.size())):
        enemy_fighters.append(get_parent().enemy_party.familiars[i])
    var battle_dialog_message = "A wild " + familiar_factory.get_and_join_display_names(enemy_fighters) + " appeared!"

    battle_dialog.open(battle_dialog_message)

func handle_timer_timeout():
    pass
