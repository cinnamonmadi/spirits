extends NinePatchRect

onready var rows = [$row_one, $row_two]

func _ready():
    close()

func open(row_one: String, row_two: String):
    visible = true
    rows[0].text = row_one
    rows[1].text = row_two

func close():
    visible = false