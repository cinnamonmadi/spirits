extends Node
class_name AnimateMove

onready var player_sprites = get_parent().get_node("player_sprites")
onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var move_callout = get_parent().get_node("ui/move_callout")
onready var tween = get_parent().get_node("tween")

const State = preload("res://battle/states/states.gd")

const ANIMATE_MOVE_DURATION: float = 0.3
const ANIMATE_MOVE_DISTANCE: int = 10

var animating_sprite
var animate_move_start_position

func begin():
    var current_action = get_parent().actions[get_parent().current_turn]
    if current_action.action == Action.ACTION_USE_MOVE:
        open_move_callout(current_action.move)

        var move_direction = 1

        if current_action.who == "player":
            animating_sprite = player_sprites.get_child(current_action.familiar)
        if current_action.who == "enemy":
            animating_sprite = enemy_sprites.get_child(3 - current_action.familiar)
            move_direction = -1

        animate_move_start_position = animating_sprite.position
        tween.interpolate_property(animating_sprite, "position", 
                                    animate_move_start_position, 
                                    animate_move_start_position + Vector2(move_direction * ANIMATE_MOVE_DISTANCE, 0),
                                    ANIMATE_MOVE_DURATION / 2)
        tween.start()

func process(_delta):
    pass

func handle_tween_finish():
    if animating_sprite.position != animate_move_start_position:
        tween.interpolate_property(animating_sprite, "position", 
                                    animating_sprite.position, 
                                    animate_move_start_position,
                                    ANIMATE_MOVE_DURATION / 2)
        tween.start()
    else:
        pass # Set state execute move

func open_move_callout(move: String):
    move_callout.get_child(0).text = move
    move_callout.visible = true