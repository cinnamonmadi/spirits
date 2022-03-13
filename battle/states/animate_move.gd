extends Node
class_name AnimateMove

onready var director = get_parent().get_node("/root/Director")

onready var player_sprites = get_parent().get_node("player_sprites")
onready var player_labels = get_parent().get_node("player_labels")
onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var move_callout = get_parent().get_node("ui/move_callout")
onready var tween = get_parent().get_node("tween")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

const ANIMATE_MOVE_DURATION: float = 0.3
const ANIMATE_MOVE_DISTANCE: int = 10

var current_action
var animating_sprite
var animate_move_start_position
var dummy_timer

func begin():
    get_parent().current_turn += 1
    current_action = get_parent().actions[get_parent().current_turn]

    if current_action.who == "player":
        animating_sprite = player_sprites.get_child(current_action.familiar)
    if current_action.who == "enemy":
        animating_sprite = enemy_sprites.get_child(3 - current_action.familiar)

    # Check to make sure the acting familiar hasn't died before we perform their action
    if current_action.who == "player" and not director.player_party.familiars[current_action.familiar].is_living():
        get_parent().set_state(State.EVALUATE_MOVE)
        return
    if current_action.who == "enemy" and not get_parent().enemy_party.familiars[current_action.familiar].is_living():
        get_parent().set_state(State.EVALUATE_MOVE)
        return

    if current_action.action == Action.USE_MOVE:
        begin_animate_attack()
    elif current_action.action == Action.SWITCH:
        begin_animate_switch()

func process(_delta):
    pass

func handle_tween_finish():
    if current_action.action == Action.USE_MOVE and animating_sprite.position != animate_move_start_position:
            tween.interpolate_property(animating_sprite, "position", 
                                        animating_sprite.position, 
                                        animate_move_start_position,
                                        ANIMATE_MOVE_DURATION / 2)
            tween.start()
    else:
        move_callout.visible = false
        get_parent().set_state(State.EXECUTE_MOVE)

func begin_animate_attack():
    get_parent().open_move_callout(Familiar.Move.keys()[current_action.move])

    var move_direction = 1
    if current_action.who == "enemy":
        move_direction = -1

    animate_move_start_position = animating_sprite.position
    tween.interpolate_property(animating_sprite, "position", 
                                animate_move_start_position, 
                                animate_move_start_position + Vector2(move_direction * ANIMATE_MOVE_DISTANCE, 0),
                                ANIMATE_MOVE_DURATION / 2)
    tween.start()

func begin_animate_switch():
    get_parent().open_move_callout("Switch")

    animating_sprite.visible = false
    if current_action.who == "player":
        player_labels.get_child(current_action.familiar).visible = false
    tween.interpolate_property(self, "dummy_timer", 0, ANIMATE_MOVE_DURATION, ANIMATE_MOVE_DURATION)
    tween.start()
