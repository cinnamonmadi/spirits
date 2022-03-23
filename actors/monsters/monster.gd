extends NPC

onready var director = get_node("/root/Director")

onready var search_area = $search_area
onready var attack_scanbox = $attack_scanbox
onready var player = get_parent().get_node("tris")

enum State {
    MOVE,
    QUIRK,
    ATTACK
}

const SEARCH_DISTANCE: int = 256
const ATTACK_RADIUS: int = 96
const MAX_QUIRK_DURATION: float = 30.0

export var chase_speed: float = 128.0
export var attack_speed: float = 256.0
export var path_speed: float = 64.0

var biting: bool = false
var quirk_timer: float = 0.0
var state = State.MOVE

func _ready():
    sprite.connect("animation_finished", self, "_on_animation_finished")
    attack_scanbox.connect("body_entered", self, "_on_attack_scanbox_body_entered")

func set_state(new_state):
    if state == State.QUIRK:
        reset_quirk_timer()
    elif state == State.ATTACK:
        disable_attack_scanbox()
    elif state == State.MOVE:
        pause_pathing()

    state = new_state

    if state == State.ATTACK:
        direction = position.direction_to(player.position)
    elif state == State.MOVE:
        resume_pathing()

func _physics_process(delta):
    if paused:
        return 
    quirk_timer -= delta
    if quirk_timer <= 0.0:
        state = State.QUIRK
    elif state == State.ATTACK:
        if sprite.frame <= 3 or sprite.frame >= 9:
            speed = 0
        else:
            speed = attack_speed
            enable_attack_scanbox()
    elif position.distance_to(player.position) <= ATTACK_RADIUS:
        speed = 0
        set_state(State.ATTACK)
    elif position.distance_to(player.position) <= SEARCH_DISTANCE:
        speed = chase_speed
        pause_pathing()
        direction = position.direction_to(player.position)
    else:
        quirk_timer -= delta
        if quirk_timer <= 0.0:
            set_state(State.QUIRK)
        speed = path_speed
        resume_pathing()

func update_animation():
    if state == State.QUIRK:
        update_sprite("quirk")
    elif state == State.ATTACK:
        update_sprite("attack")
    else:
        .update_animation()

func _on_animation_finished():
    if state == State.QUIRK:
        reset_quirk_timer()
        state = State.MOVE
    elif state == State.ATTACK:
        disable_attack_scanbox()
        resume_pathing()
        state = State.MOVE

func disable_attack_scanbox():
    for attack_collider in attack_scanbox.get_children():
        attack_collider.disabled = true

func enable_attack_scanbox():
    disable_attack_scanbox()
    var attacking_direction
    if abs(direction.x) >= abs(direction.y):
        if direction.x > 0:
            attacking_direction = "right"
        else:
            attacking_direction = "left"
    else:
        if direction.y > 0:
            attacking_direction = "down"
        else:
            attacking_direction = "up"
    attack_scanbox.get_node("collider_" + attacking_direction).disabled = false

func _on_attack_scanbox_body_entered(body):
    if body.name == "tris":
        body.handle_monster_attack(self)

func reset_quirk_timer():
    quirk_timer = director.rng.randf_range(0.85, 1.0) * MAX_QUIRK_DURATION
