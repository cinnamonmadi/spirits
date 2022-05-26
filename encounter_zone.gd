extends Area2D

onready var director = get_node("/root/Director")

export(Array, Resource) var species
export(Array, float) var rate
export(Array, String) var level

var level_ranges = []

var player = null
var player_position = null

var encounter_countdown: int

func _ready():
    var _return_val = self.connect("body_entered", self, "_on_body_entered")
    _return_val = self.connect("body_exited", self, "_on_body_exited")
    reset_encounter_countdown()

    for level_range_string in level:
        if "," in level_range_string:
            var values = level_range_string.split(",")
            level_ranges.append([int(values[0]), int(values[1])])
        else:
            var value = int(level_range_string)
            level_ranges.append([value, value])

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
    var generated_level = 1

    for i in range(0, species.size()):
        spawn_value += rate[i]
        if roll <= spawn_value:
            generated_species = species[i]
            generated_level = director.rng.randi_range(level_ranges[i][0], level_ranges[i][1])
            break
    if generated_species == null:
        generated_species = species[0]
        generated_level = director.rng.randi_range(level_ranges[0][0], level_ranges[0][1])

    return Familiar.new(generated_species, generated_level)
