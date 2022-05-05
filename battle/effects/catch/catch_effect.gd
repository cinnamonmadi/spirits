extends Node2D

signal animation_finished

onready var back_layer = $back_layer
onready var front_layer = $front_layer

var num_ticks: int
var ticks: int 
var success: bool
var is_playing: bool
var sprite_to_hide

func _ready():
    front_layer.connect("animation_finished", self, "_front_animation_finished")
    back_layer.connect("animation_finished", self, "_back_animation_finished")

func start(number_of_ticks: int, is_successful: bool, sprite):
    num_ticks = number_of_ticks
    ticks = 0
    success = is_successful
    sprite_to_hide = sprite

    visible = true
    back_layer.visible = true
    back_layer.play("pentagram")
    front_layer.visible = true
    front_layer.play("pentagram")

    is_playing = true

func _front_animation_finished():
    if front_layer.animation == "pentagram":
        front_layer.visible = false
    elif front_layer.animation == "catch":
        finish()

func _back_animation_finished():
    if back_layer.animation == "pentagram":
        if num_ticks == 0:
            back_layer.play("catch")
        else:
            back_layer.play("pentagram_loop")
    elif back_layer.animation == "pentagram_loop":
        ticks += 1
        if ticks != num_ticks:
            back_layer.play("pentagram_tick")
        else:
            back_layer.play("catch")
    elif back_layer.animation == "pentagram_tick":
        back_layer.play("pentagram_loop")
    elif back_layer.animation == "catch":
        if success:
            back_layer.visible = false
            front_layer.visible = true
            sprite_to_hide.visible = false
            front_layer.play("catch")
        else:
            finish()

func finish():
    visible = false
    back_layer.visible = false
    front_layer.visible = false
    back_layer.stop()
    front_layer.stop()
    is_playing = false
    emit_signal("animation_finished")
