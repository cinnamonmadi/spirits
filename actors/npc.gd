extends Actor

class_name NPC

const input_direction_names = ["up", "right", "down", "left"]
const input_direction_vectors = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

enum Path {
    MOVE,
    FACE,
    WAIT,
}

export var path = []

var _path = []
var path_index: int = 0
var path_timer: float = 0

func _ready():
    SPEED = 0.5
    parse_path()

func parse_path():
    _path.append([Path.MOVE, position])
    var previous_path_position = position

    for path_string in path:
        var path_string_parts = path_string.split(",")
        var path_command = path_string_parts[0]
        var path_value = path_string_parts[1]

        if path_command == "face":
            for i in range(0, input_direction_names.size()):
                if path_value == input_direction_names[i]:
                    _path.append([Path.FACE, input_direction_vectors[i]])
        elif path_command == "wait":
            _path.append([Path.WAIT, float(path_value)]) 
        else:
            for i in range(0, input_direction_names.size()):
                if path_command == input_direction_names[i]:
                    var new_path_position = previous_path_position + (input_direction_vectors[i] * TILE_SIZE * int(path_value))
                    _path.append([Path.MOVE, new_path_position])

                    previous_path_position = new_path_position


func _physics_process(delta):
    update_path(delta)
    update_sprite()

func update_path(delta):
    progress_path(delta)
    while should_increment_path():
        increment_path()

func progress_path(delta):
    var current_path_action = _path[path_index][0]
    if current_path_action == Path.MOVE:
        move()
        if not is_moving_between_tiles() and position != _path[path_index][1]:
            try_find_next_target(position.direction_to(_path[path_index][1]))
    elif current_path_action == Path.WAIT:
        path_timer -= delta

func should_increment_path() -> bool:
    var current_path_action = _path[path_index][0]
    if current_path_action == Path.MOVE:
        return not is_moving_between_tiles() and position == _path[path_index][1]
    elif current_path_action == Path.FACE:
        return facing_direction == _path[path_index][1]
    elif current_path_action == Path.WAIT:
        return path_timer <= 0
    return false

func increment_path():
    path_index = (path_index + 1) % _path.size()
    var current_path_action = _path[path_index][0]
    if current_path_action == Path.MOVE:
        try_find_next_target(position.direction_to(_path[path_index][1]))
    elif current_path_action == Path.FACE:
        facing_direction = _path[path_index][1]
    elif current_path_action == Path.WAIT:
        path_timer = _path[path_index][1]
