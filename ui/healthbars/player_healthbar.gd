extends Control

const INTERPOLATE_DURATION: float = 0.5

onready var healthbar = $healthbar
onready var manabar = $manabar
onready var expbar = $expbar
onready var name_label = $name_label
onready var level_label = $level_label
onready var health_label = $health_label
onready var mana_label = $mana_label

var displayed_health: float = 0
var displayed_max_health: int
var displayed_mana: float = 0
var displayed_max_mana: int
var displayed_exp: float = 0
var displayed_max_exp: int

var interpolate_timer: float
var health_interpolate_to: int
var health_interpolate_from: int
var mana_interpolate_to: int
var mana_interpolate_from: int
var exp_interpolate_to: int
var exp_interpolate_from: int

var familiar: Familiar = null

func _ready():
    healthbar.region_rect.size.y = healthbar.texture.get_height()
    manabar.region_rect.size.y = manabar.texture.get_height()
    expbar.region_rect.size.y = expbar.texture.get_height()

func is_interpolating():
    if familiar == null:
        return false
    return (displayed_health != familiar.health) or (displayed_mana != familiar.mana) 

func set_familiar(value: Familiar):
    familiar = value
    displayed_health = familiar.health
    displayed_max_health = familiar.max_health
    displayed_mana = familiar.mana
    displayed_max_mana = familiar.max_mana
    displayed_exp = familiar.get_current_experience()
    displayed_max_exp = familiar.get_experience_tnl()
    refresh()

func refresh():
    var health_percent_full: float
    if displayed_max_health == 0:
        health_percent_full = 0
    else:
        health_percent_full = displayed_health / float(displayed_max_health)
    healthbar.region_rect.size.x = int(health_percent_full * healthbar.texture.get_width())

    var mana_percent_full: float
    if displayed_max_mana == 0:
        mana_percent_full = 0
    else:
        mana_percent_full = displayed_mana / float(displayed_max_mana)
    manabar.region_rect.size.x = int(mana_percent_full * manabar.texture.get_width())

    var exp_percent_full: float
    if displayed_max_exp == 0:
        exp_percent_full = 0
    else:
        exp_percent_full = displayed_exp / float(displayed_max_exp)
    expbar.region_rect.size.x = int(exp_percent_full * expbar.texture.get_width())

    name_label.text = familiar.get_display_name()
    level_label.text = String(familiar.get_level())
    health_label.text = String(int(displayed_health)) + "/" + String(displayed_max_health)
    mana_label.text = String(int(displayed_mana))

func _process(delta):
    if familiar == null:
        return

    if interpolate_timer <= 0 and (familiar.health != displayed_health or familiar.mana != displayed_mana):
        health_interpolate_from = int(displayed_health)
        health_interpolate_to = familiar.health
        mana_interpolate_from = int(displayed_mana)
        mana_interpolate_to = familiar.mana
        interpolate_timer = INTERPOLATE_DURATION
    if familiar.get_current_experience() != displayed_exp or familiar.get_experience_tnl() != displayed_max_exp:
        displayed_exp = familiar.get_current_experience()
        displayed_max_exp = familiar.get_experience_tnl()
        refresh()

    if interpolate_timer != 0:
        interpolate_timer -= delta
        if interpolate_timer <= 0:
            displayed_health = health_interpolate_to
            displayed_mana = mana_interpolate_to
            interpolate_timer = 0
            refresh()
        else:
            var percent_complete: float = 1 - (interpolate_timer / INTERPOLATE_DURATION)
            displayed_health = health_interpolate_from + (float(health_interpolate_to - health_interpolate_from) * percent_complete)
            displayed_mana = mana_interpolate_from + (float(mana_interpolate_to - mana_interpolate_from) * percent_complete)
            refresh()
