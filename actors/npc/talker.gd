extends NPC
class_name Talker

export var dialog: String = ""

func _ready():
    add_to_group("talkers")
    speed = 64.0

func start_speaking(player_direction: Vector2):
    pause_pathing()
    # Face player
    for i in range(0, 4):
        if direction_vectors[i] == player_direction:
            facing_direction = direction_vectors[(i + 2) % 4]

func stop_speaking():
    resume_pathing()
