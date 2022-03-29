extends Node
class_name NameFamiliar

onready var director = get_node("/root/Director")

onready var centered_familiar = get_parent().get_node("ui/centered_familiar")
onready var dialog = get_parent().get_node("ui/dialog")
onready var dialog_yes_no = get_parent().get_node("ui/dialog_yes_no")
onready var namebox = get_parent().get_node("ui/namebox")
onready var namebox_label = get_parent().get_node("ui/namebox/label")
onready var player_sprites = get_parent().get_node("player_sprites")
onready var player_labels = get_parent().get_node("player_labels")

const State = preload("res://battle/states/states.gd")

var naming_familiar
var pending_name = ""

func begin(params):
    naming_familiar = params.familiar
    pending_name = ""

    for sprite in player_sprites.get_children():
        sprite.visible = false
    for label in player_labels.get_children():
        label.visible = false

    get_parent().close_all_menus()
    centered_familiar.texture = load(naming_familiar.get_portrait_path())
    centered_familiar.visible = true
    dialog.open_with([["Give a nickname to the", "captured " + naming_familiar.get_display_name() + "?"]])
    print("here", director.player_party.familiars.size())

func _input(event):
    if not namebox.visible:
        return
    if event is InputEventKey and event.pressed and not event.is_echo():
        if event.scancode >= KEY_A and event.scancode <= KEY_Z:
            var new_char = char(event.scancode)
            if not Input.is_action_pressed("back"):
                new_char = new_char.to_lower()
            if pending_name.length() != 10:
                pending_name += new_char
        elif event.scancode == KEY_SPACE:
            if pending_name.length() != 10:
                pending_name += " "
        elif event.scancode == KEY_BACKSPACE:
            if pending_name != "":
                pending_name = pending_name.substr(0, pending_name.length() - 1)
        namebox_label.text = pending_name

func process(_delta):
    if namebox.visible:
        if Input.is_action_just_pressed("start"):
            if pending_name.length() != 0:
                naming_familiar.nickname = pending_name
                exit_state()
    elif dialog.is_waiting():
        if not dialog_yes_no.visible:
            dialog_yes_no.open()
        var action = dialog_yes_no.check_for_input()
        if action == "Yes":
            namebox.visible = true
            namebox_label.text = ""
            dialog_yes_no.close()
        elif action == "No":
            exit_state()
    else:
        if Input.is_action_just_pressed("action"):
            dialog.progress()
    
func handle_tween_finish():
    pass

func handle_timer_timeout():
    pass

func exit_state():
    namebox.visible = false
    centered_familiar.visible = false
    dialog.close()
    get_parent().set_state(State.ANNOUNCE_WINNER, { "first_time_entering_state": false })
