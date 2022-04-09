extends AnimatedSprite

onready var player = get_parent().get_node("tris")

onready var hurtbox = $hurtbox

var direction: Vector2

func _ready():
    var _return_value = self.connect("animation_finished", self, "_on_animation_finished")
    hurtbox.connect("body_entered", self, "_on_body_entered")
    frame = 0
    position = player.position
    disable_hurtbox()
    play(player.get_direction_name(direction))

func disable_hurtbox():
    for child in hurtbox.get_children():
        child.disabled = true

func enable_hurtbox():
    hurtbox.get_node(player.get_direction_name(direction)).disabled = false

func _process(_delta):
    if frame >= 8 and frame <= 9:
        enable_hurtbox()
    else:
        disable_hurtbox()

func _on_animation_finished():
    stop()
    queue_free()

func _on_body_entered(body):
    if frame >= 8 and frame <= 9 and body is Monster:
        stop()
        player.handle_attacked_monster(body, self)
