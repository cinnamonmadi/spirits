extends Node
class_name AnimateMove

onready var director = get_parent().get_node("/root/Director")
onready var familiar_factory = get_parent().get_node("/root/FamiliarFactory")

onready var player_sprites = get_parent().get_node("player_sprites")
onready var player_labels = get_parent().get_node("player_labels")
onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var battle_dialog = get_parent().get_node("ui/battle_dialog")
onready var tween = get_parent().get_node("tween")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

const item_effect_scene = preload("res://battle/effects/item_effect.tscn")

const ANIMATE_MOVE_DURATION: float = 0.3
const ANIMATE_MOVE_DISTANCE: int = 10

var current_turn
var current_action
var animating_sprite
var animate_move_start_position
var dummy_timer
var effect

func begin(_params):
    get_parent().current_turn += 1
    current_action = get_parent().actions[get_parent().current_turn]

    # Determine animating sprite
    if current_action.who == "player":
        animating_sprite = player_sprites.get_child(current_action.familiar)
    if current_action.who == "enemy":
        animating_sprite = enemy_sprites.get_child(1 - current_action.familiar)

    # Check to make sure the acting familiar hasn't died before we perform their action
    if current_action.who == "player" and not director.player_party.familiars[current_action.familiar].is_living():
        get_parent().set_state(State.EVALUATE_MOVE, {})
        return
    if current_action.who == "enemy" and not get_parent().enemy_party.familiars[current_action.familiar].is_living():
        get_parent().set_state(State.EVALUATE_MOVE, {})
        return

    if current_action.action == Action.USE_MOVE:
        begin_animate_attack()
    elif current_action.action == Action.SWITCH:
        begin_animate_switch()
    elif current_action.action == Action.USE_ITEM:
        begin_animate_item()

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
        get_parent().set_state(State.EXECUTE_MOVE, {})

func handle_timer_timeout():
    pass

func handle_effect_finish():
    effect.stop()
    effect.queue_free()
    get_parent().set_state(State.EXECUTE_MOVE, {})

func begin_animate_attack():
    var battle_dialog_message = ""
    if current_action.who == "player":
        battle_dialog_message += familiar_factory.get_display_name(director.player_party.familiars[current_action.familiar])
    if current_action.who == "enemy":
        battle_dialog_message += "Enemy " + familiar_factory.get_display_name(get_parent().enemy_party.familiars[current_action.familiar])
    battle_dialog_message += " used " + familiar_factory.get_move_name(current_action.move) + "!"

    battle_dialog.open_and_wait(battle_dialog_message, get_parent().BATTLE_DIALOG_WAIT_TIME)

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
    battle_dialog.close()

    animating_sprite.visible = false
    if current_action.who == "player":
        player_labels.get_child(current_action.familiar).visible = false
    tween.interpolate_property(self, "dummy_timer", 0, ANIMATE_MOVE_DURATION, ANIMATE_MOVE_DURATION)
    tween.start()

func begin_animate_item():
    var battle_dialog_message = ""
    if current_action.who == "player":
        battle_dialog_message += "You"
    elif current_action.who == "enemy":
        battle_dialog_message += "Enemy"
    battle_dialog_message += " used " + Inventory.Item.keys()[current_action.item]

    battle_dialog.open(battle_dialog_message, get_parent().BATTLE_DIALOG_WAIT_TIME)

    effect = item_effect_scene.instance()
    effect.connect("animation_finished", self, "handle_effect_finish")
    get_parent().add_child(effect)

    if current_action.target_who == "player":
        effect.position = player_sprites.get_child(current_action.target_familiar).position
    else:
        effect.position = enemy_sprites.rect_position + enemy_sprites.get_child(1 - current_action.target_familiar).position

    effect.play("default")
