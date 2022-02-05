extends Area2D

onready var map = get_parent().find_node("tilemap")
onready var sprite = $sprite

const SPEED: int = 1
const TILE_SIZE: int = 16
const input_direction_names = ["up", "right", "down", "left"]
const input_direction_vectors = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

var input_direction: Vector2
var target_position: Vector2
var facing_direction: Vector2

func _ready():
    input_direction = Vector2.ZERO
    target_position = Vector2.ZERO
    map.reserve_tile(position)

func handle_input():
    for i in range(0, input_direction_names.size()):
        if Input.is_action_just_pressed(input_direction_names[i]):
            input_direction = input_direction_vectors[i]
        elif Input.is_action_just_released(input_direction_names[i]):
            input_direction = Vector2.ZERO
            for j in range(0, input_direction_names.size()):
                if i == j:
                    continue
                if Input.is_action_pressed(input_direction_names[j]):
                    input_direction = input_direction_vectors[j]
                    break

func _physics_process(_delta):
    handle_input()
    move()
    update_sprite()

func move():
    var is_moving_between_tiles = target_position != Vector2.ZERO
    if is_moving_between_tiles:
        var movement_direction = position.direction_to(target_position)

        facing_direction = movement_direction
        position += movement_direction * SPEED
        if position == target_position:
            # Update the collision map
            var old_position = position - (movement_direction * TILE_SIZE)
            map.free_tile(old_position)
            map.reserve_tile(position)

            target_position = Vector2.ZERO
            is_moving_between_tiles = false
    if not is_moving_between_tiles and input_direction != Vector2.ZERO:
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
