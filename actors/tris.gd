extends Actor

const input_direction_names = ["up", "right", "down", "left"]
const input_direction_vectors = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

var input_direction: Vector2

func _ready():
    input_direction = Vector2.ZERO

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
    move()
    try_find_next_target(input_direction)
    handle_input()
    update_sprite()
