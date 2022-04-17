extends Control

const INTERPOLATE_DURATION: float = 0.5

onready var familiar_factory = get_node("/root/FamiliarFactory")

onready var bar_full = $bar_full
onready var name_label = $name_label
onready var level_label = $level_label
onready var health_label = $health_label

var displayed_health: float = 0
var displayed_max_health: int

var interpolate_timer: float
var health_interpolate_to: int
var health_interpolate_from: int

var familiar: Familiar = null

func _ready():
    bar_full.region_rect.size.y = bar_full.texture.get_height()

func is_interpolating():
    if familiar == null:
        return false
    return displayed_health != familiar.health

func set_familiar(value: Familiar):
    familiar = value
    displayed_health = familiar.health
    displayed_max_health = familiar.max_health
    refresh()

func refresh():
    var percent_full: float = displayed_health / float(displayed_max_health)
    bar_full.region_rect.size.x = int(percent_full * bar_full.texture.get_width())

    name_label.text = familiar_factory.get_display_name(familiar)
    level_label.text = String(familiar.get_level())
    health_label.text = String(int(displayed_health)) + "/" + String(displayed_max_health)

func _process(delta):
    if familiar == null:
        return

    if interpolate_timer <= 0 and familiar.health != displayed_health:
        health_interpolate_from = int(displayed_health)
        health_interpolate_to = familiar.health
        interpolate_timer = INTERPOLATE_DURATION

    if interpolate_timer != 0:
        interpolate_timer -= delta
        if interpolate_timer <= 0:
            displayed_health = health_interpolate_to
            refresh()
        else:
            var percent_complete: float = 1 - (interpolate_timer / INTERPOLATE_DURATION)
            displayed_health = health_interpolate_from + (float(health_interpolate_to - health_interpolate_from) * percent_complete)
            refresh()
