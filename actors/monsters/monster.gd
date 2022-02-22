extends NPC

onready var search_area = $search_area
onready var attack_scanbox = $attack_scanbox
onready var player = get_parent().get_node("tris")

const SEARCH_DISTANCE: int = 256
const BITE_RADIUS: int = 96

export var chase_speed: float = 128.0
export var bite_speed: float = 256.0
export var path_speed: float = 64.0

var biting: bool = false

func _ready():
    sprite.connect("animation_finished", self, "_on_animation_finished")
    attack_scanbox.connect("body_entered", self, "_on_attack_scanbox_body_entered")

func _physics_process(_delta):
    if paused:
        return 
    if biting:
        if sprite.frame <= 3 or sprite.frame >= 9:
            speed = 0
        else:
            speed = bite_speed
            enable_attack_scanbox()
    elif position.distance_to(player.position) <= BITE_RADIUS:
        biting = true
        pause_pathing()
        direction = position.direction_to(player.position)
        speed = 0
    elif position.distance_to(player.position) <= SEARCH_DISTANCE:
        speed = chase_speed
        pause_pathing()
        direction = position.direction_to(player.position)
    else:
        speed = path_speed
        resume_pathing()

func update_animation():
    if biting:
        update_sprite("bite")
    else:
        .update_animation()

func _on_animation_finished():
    if biting:
        biting = false
        disable_attack_scanbox()
        resume_pathing()

func disable_attack_scanbox():
    for attack_collider in attack_scanbox.get_children():
        attack_collider.disabled = true

func enable_attack_scanbox():
    disable_attack_scanbox()
    attack_scanbox.get_node("collider_" + get_direction_name(facing_direction)).disabled = false

func _on_attack_scanbox_body_entered(body):
    if body.name == "tris":
        body.handle_monster_attack(self)