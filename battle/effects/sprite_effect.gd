extends Node
class_name SpriteEffect

enum SpriteEffectType {
    NUDGE,
    FLICKER
}

var type: int
var sprite: Sprite
var is_enemy: bool

var timer: float
var duration: float
var counter: int

var is_finished: bool = true

func begin(_type: int, _sprite: Sprite, _is_enemy: bool):
    type = _type
    sprite = _sprite
    is_enemy = _is_enemy
    is_finished = false

    if type == SpriteEffectType.FLICKER:
        counter = 6
        duration = 0.075
        timer = duration
        sprite.visible = false

func _process(delta):
    if is_finished:
        return
    if type == SpriteEffectType.FLICKER:
        process_flicker(delta)

func process_flicker(delta):
    timer -= delta
    if timer <= 0:
        timer += duration
        counter -= 1
        if counter == 0:
            sprite.visible = true
            is_finished = true
        else:
            sprite.visible = not sprite.visible