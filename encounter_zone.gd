extends Area2D

onready var director = get_node("/root/Director")

export(Array, Resource) var species
export(Array, float) var rate
export var level_low: int = 1
export var level_high: int = 1

var player = null
var player_position = null

var encounter_countdown: int

func _ready():
    var _return_val = self.connect("body_entered", self, "_on_body_entered")
    _return_val = self.connect("body_exited", self, "_on_body_exited")
    reset_encounter_countdown()

func _on_body_entered(body):
    if body.name == "tris":
        player = body
        player_position = player.position

func _on_body_exited(body):
    if body.name == "tris":
        player = null

func _process(_delta):
    if player == null:
        return
    if player.position != player_position:
        var distance_moved = (player.position - player_position).length()
        player_position = player.position

        encounter_countdown -= distance_moved
        if encounter_countdown <= 0:
            reset_encounter_countdown()
            player.input_direction = Vector2.ZERO
            director.enemy_party.familiars = [generate_enemy_familiar(), generate_enemy_familiar()]
            get_parent().init_start_battle()

func reset_encounter_countdown():
    encounter_countdown = director.rng.randi_range(4, 20) * 32

func generate_enemy_familiar():
    var roll = director.rng.randf_range(0.0, 1.0)
    var spawn_value = 0.0

    var generated_species = null

    for i in range(0, species.size()):
        spawn_value += rate[i]
        if roll <= spawn_value:
            generated_species = species[i]
    if generated_species == null:
        generated_species = species[0]

    var level = director.rng.randi_range(level_low, level_high)
    return Familiar.new(generated_species, level)
