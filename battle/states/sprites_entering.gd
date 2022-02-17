extends Node
class_name SpritesEntering

onready var witch = get_parent().get_node("witch")
onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var tween = get_parent().get_node("tween")

const State = preload("res://battle/states/states.gd")

const SPRITES_ENTERING_DURATION: float = 1.0

func begin():
    # Setup the enemy familiar sprites
    for i in range(0, get_parent().enemy_party.familiars.size()):
        enemy_sprites.get_child(3 - i).texture = load(get_parent().enemy_party.familiars[i].get_portrait_path())
        enemy_sprites.get_child(3 - i).visible = true
    # Set the sprites in their initial positions to enter from
    tween.interpolate_property(enemy_sprites, "rect_position", 
                                Vector2(-enemy_sprites.rect_size.x, enemy_sprites.rect_position.y), 
                                Vector2(enemy_sprites.rect_position.x, enemy_sprites.rect_position.y), 
                                SPRITES_ENTERING_DURATION)
    tween.interpolate_property(witch, "rect_position", 
                                Vector2(get_parent().SCREEN_WIDTH, witch.rect_position.y), 
                                Vector2(witch.rect_position.x, witch.rect_position.y), 
                                SPRITES_ENTERING_DURATION)
    # Begin the interpolation
    tween.start()

func process(_delta):
    pass

func handle_tween_finish():
    for i in range(0, get_parent().enemy_party.familiars.size()):
        get_parent().update_enemy_label(i)
    get_parent().set_state(State.SUMMON_FAMILIARS)
