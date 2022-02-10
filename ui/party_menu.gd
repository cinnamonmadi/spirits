extends ColorRect

onready var choice_menu = $choice_menu
onready var choices = $choice_menu/choices/col_1.get_children()

func _ready():
    visible = false

func open(familiars):
    choice_menu.choices = [[]]
    for i in range(0, familiars.size()):
        choices[i].text = familiars[i].get_display_name()
        choices[i].find_node("level").text = "LVL " + String(familiars[i].level)
        choices[i].find_node("health").text = "HP:" + String(familiars[i].health) + "/" + String(familiars[i].max_health) + " MP:" + String(familiars[i].mana) + "/" + String(familiars[i].max_mana)
        choices[i].visible = true
        choice_menu.choices[0].append(choices[i])
    choice_menu.open()
    visible = true

func close():
    for choice in choices:
        choice.text = ""
        choice.visible = false
    choice_menu.close()
    visible = false

func check_for_input():
    return choice_menu.check_for_input()
