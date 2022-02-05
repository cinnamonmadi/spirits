extends Area2D

class_name Actor

onready var map = get_parent().find_node("tilemap")
onready var sprite = $sprite

const TILE_SIZE: int = 16

var SPEED: float = 1
var target_position: Vector2
var facing_direction: Vector2

func _ready():
    target_position = Vector2.ZERO
    map.reserve_tile(position)

func is_moving_between_tiles() -> bool:
    return target_position != Vector2.ZERO

func move():
    if not is_moving_between_tiles():
        return

    # Perform movement
    var movement_direction = position.direction_to(target_position)
    facing_direction = movement_direction
    position += movement_direction * SPEED

    # Check if actor has reached their target position
    if position == target_position:
        # Update the collision map
        var old_position = position - (movement_direction * TILE_SIZE)
        map.free_tile(old_position)
        map.reserve_tile(position)

        target_position = Vector2.ZERO

func try_find_next_target(input_direction: Vector2):
    if is_moving_between_tiles() or input_direction == Vector2.ZERO:
        return
    var desired_target_position = position + (input_direction * TILE_SIZE) 
    if map.is_tile_free(desired_target_position):
        target_position = desired_target_position
        map.reserve_tile(target_position)

func update_sprite():
    if facing_direction == Vector2.UP:
        sprite.play("up")
    elif facing_direction == Vector2.DOWN:
        sprite.play("down")
    else:
        sprite.play("side")
    sprite.flip_h = facing_direction == Vector2.LEFT

    if target_position == Vector2.ZERO:
        sprite.stop()
        sprite.frame = 0
