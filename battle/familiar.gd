class_name Familiar
# Stats
var family_name: String
var level: int
var experience: int

var health: int
var max_health: int

var mana: int
var max_mana: int

var attack: int
var defense: int
var speed: int

func get_portrait_path():
    return "res://battle/familiars/" + family_name.to_lower().replace(" ", "_") + ".png"
