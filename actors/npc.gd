extends Actor
class_name NPC

enum Path {
    MOVE,
    FACE,
    WAIT,
}

var is_pathing: bool = true
var old_facing_direction: Vector2

export var path = []

var _path = []
var path_index: int = 0
var path_timer: float = 0

func _ready():
    add_to_group("npcs")
    parse_path()
    resume_pathing()

func pause_pathing():
    is_pathing = false
    old_facing_direction = facing_direction

func resume_pathing():
    is_pathing = true
    facing_direction = old_facing_direction

func parse_path():
    _path.append([Path.MOVE, position])
    var previous_path_position = position

    for path_string in path:
        var path_string_parts = path_string.split(",")
        var path_command = path_string_parts[0]
        var path_value = path_string_parts[1]

        if path_command == "face":
            _path.append([Path.FACE, get_direction_vector(path_value)])
        elif path_command == "wait":
            _path.append([Path.WAIT, float(path_value)]) 
        else:
            var path_direction = get_direction_vector(path_command)
            var new_path_position = previous_path_position + (path_direction * TILE_SIZE * int(path_value))
            _path.append([Path.MOVE, new_path_position])

            previous_path_position = new_path_position

func _physics_process(delta):
    if paused:
        return
    if is_pathing:
        update_path(delta)

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
