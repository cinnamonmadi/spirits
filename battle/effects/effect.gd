extends Sprite

signal animation_finished

onready var timer = $timer

var duration: float

func _ready():
    timer.connect("timeout", self, "_on_timeout")

func setup(path: String, frames: int, fps: float):
    texture = load(path)
    hframes = frames
    frame = 0
    duration = 1.0 / fps

func start():
    timer.start(duration)

func _on_timeout():
    if frame == hframes - 1:
        timer.stop()
        emit_signal("animation_finished")
        queue_free()
    else:
        frame += 1
