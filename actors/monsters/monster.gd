extends NPC

onready var search_area = $search_area
onready var player = get_parent().get_node("tris")

const SEARCH_DISTANCE: int = 128

export var chase_speed: float = 128.0
export var path_speed: float = 64.0

func _physics_process(_delta):
    if position.distance_to(player.position) <= SEARCH_DISTANCE:
        speed = chase_speed
        pause_pathing()
        direction = position.direction_to(player.position)
    else:
        speed = path_speed
        resume_pathing()