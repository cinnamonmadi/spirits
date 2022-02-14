extends KinematicBody2D

class_name NPC

onready var sprite = $sprite

const TILE_SIZE: int = 64
const direction_names = ["up", "right", "down", "left"]
const direction_vectors = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

enum Path {
    MOVE,
    FACE,
    WAIT,
}

var direction: Vector2
var facing_direction: Vector2
var speed: float = 64.0

var is_speaking: bool = false
var old_facing_direction: Vector2

var paused: bool = false

export var path = []
export var dialog: String = ""

var _path = []
var path_index: int = 0
var path_timer: float = 0

func _ready():
    add_to_group("npcs")
    add_to_group("pausables")
    parse_path()

func start_speaking(player_direction: Vector2):
    is_speaking = true
    old_facing_direction = facing_direction
    # Face player
    for i in range(0, 4):
        if direction_vectors[i] == player_direction:
            facing_direction = direction_vectors[(i + 2) % 4]

func stop_speaking():
    is_speaking = false
    facing_direction = old_facing_direction

func parse_path():
    _path.append([Path.MOVE, position])
    var previous_path_position = position

    for path_string in path:
        var path_string_parts = path_string.split(",")
        var path_command = path_string_parts[0]
        var path_value = path_string_parts[1]

        if path_command == "face":
            for i in range(0, direction_names.size()):
                if path_value == direction_names[i]:
                    _path.append([Path.FACE, direction_vectors[i]])
        elif path_command == "wait":
            _path.append([Path.WAIT, float(path_value)]) 
        else:
            for i in range(0, direction_names.size()):
                if path_command == direction_names[i]:
                    var new_path_position = previous_path_position + (direction_vectors[i] * TILE_SIZE * int(path_value))
                    _path.append([Path.MOVE, new_path_position])

                    previous_path_position = new_path_position

func _physics_process(delta):
    if paused:
        sprite.stop()
        return
    if not is_speaking:
        update_path(delta)
    update_sprite()

func update_path(delta):
    progress_path(delta)
    while should_increment_path():
        increment_path()

func progress_path(delta):
    var current_path_action = _path[path_index][0]
    if current_path_action == Path.MOVE:
        if position.distance_to(_path[path_index][1]) <= speed * delta:
            position = _path[path_index][1]
            direction = Vector2.ZERO
        else:
            direction = position.direction_to(_path[path_index][1])
            var old_position = position
            var collision = move_and_collide(direction * speed * delta)
            if collision:
                position = old_position
                direction = Vector2.ZERO
    elif current_path_action == Path.WAIT:
        path_timer -= delta

func should_increment_path() -> bool:
    var current_path_action = _path[path_index][0]
    if current_path_action == Path.MOVE:
        return direction == Vector2.ZERO and position == _path[path_index][1]
    elif current_path_action == Path.FACE:
        return facing_direction == _path[path_index][1]
    elif current_path_action == Path.WAIT:
        return path_timer <= 0
    return false

func increment_path():
    path_index = (path_index + 1) % _path.size()
    var current_path_action = _path[path_index][0]
    if current_path_action == Path.MOVE:
        pass
    elif current_path_action == Path.FACE:
        facing_direction = _path[path_index][1]
    elif current_path_action == Path.WAIT:
        path_timer = _path[path_index][1]

func update_sprite():
    if not is_speaking:
        if direction.x == 1:
            facing_direction = Vector2.RIGHT
        elif direction.x == -1:
            facing_direction = Vector2.LEFT
        elif direction.y == 1:
            facing_direction = Vector2.DOWN
        elif direction.y == -1:
            facing_direction = Vector2.UP
    var animation_prefix: String
    if is_speaking or direction == Vector2.ZERO:
        animation_prefix = "idle_"
    else:
        animation_prefix = "move_"
    for index in range(0, 4):
        if facing_direction == direction_vectors[index]:
            sprite.play(animation_prefix + direction_names[index])
