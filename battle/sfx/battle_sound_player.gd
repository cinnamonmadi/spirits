extends AudioStreamPlayer

onready var HIT_NORMAL = preload("res://battle/sfx/hit_normal.wav")
onready var HIT_SUPER = preload("res://battle/sfx/hit_super.wav")
onready var HIT_WEAK = preload("res://battle/sfx/hit_weak.wav")

func _ready():
    var _return_value = self.connect("finished", self, "_on_finish")

func play_sound(sound):
    if playing:
        stop()
    stream = sound
    play()

func _on_finish():
    stop()