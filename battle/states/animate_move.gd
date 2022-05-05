extends Node
class_name AnimateMove

onready var director = get_parent().get_node("/root/Director")
onready var familiar_factory = get_parent().get_node("/root/FamiliarFactory")
onready var effect_factory = get_parent().get_node("/root/EffectFactory")

onready var player_sprites = get_parent().get_node("player_sprites")
onready var player_labels = get_parent().get_node("player_labels")
onready var enemy_sprites = get_parent().get_node("enemy_sprites")
onready var battle_dialog = get_parent().get_node("ui/battle_dialog")
onready var tween = get_parent().get_node("tween")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

const ANIMATE_MOVE_DURATION: float = 0.3
const ANIMATE_MOVE_DISTANCE: int = 10

var current_action
var animating_sprite
var animate_move_start_position
var dummy_timer

func begin(_params):
    current_action = get_parent().actions[0]

    # Determine animating sprite
    if current_action.who == "player":
        animating_sprite = player_sprites.get_child(current_action.familiar)
    if current_action.who == "enemy":
        animating_sprite = enemy_sprites.get_child(1 - current_action.familiar)

    if current_action.action == Action.USE_MOVE:
        begin_animate_attack()
    elif current_action.action == Action.SWITCH:
        begin_animate_switch()
    elif current_action.action == Action.USE_ITEM:
        begin_animate_item()
    elif current_action.action == Action.REST:
        begin_animate_rest()

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
    get_parent().set_state(State.EXECUTE_MOVE, {})

func message_familiar_name():
    if current_action.who == "player":
        return familiar_factory.get_display_name(director.player_party.familiars[current_action.familiar])
    if current_action.who == "enemy":
        return "Enemy " + familiar_factory.get_display_name(get_parent().enemy_party.familiars[current_action.familiar])

func begin_animate_attack():
    var battle_dialog_message = message_familiar_name() + " used " + familiar_factory.get_move_name(current_action.move) + "!"

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

func begin_animate_rest():
    var battle_dialog_message = message_familiar_name() + " took a rest."
    battle_dialog.open_and_wait(battle_dialog_message, get_parent().BATTLE_DIALOG_WAIT_TIME)

    tween.interpolate_property(self, "dummy_timer", 0, ANIMATE_MOVE_DURATION, ANIMATE_MOVE_DURATION)
    tween.start()

func begin_animate_item():
    var battle_dialog_message = message_familiar_name() + " used " + Inventory.Item.keys()[current_action.item]
    battle_dialog.open_and_wait(battle_dialog_message, get_parent().BATTLE_DIALOG_WAIT_TIME)

    var effect = effect_factory.create_effect(effect_factory.Effect.ITEM)
    effect.connect("animation_finished", self, "handle_effect_finish")
    get_parent().add_child(effect)
    effect.start()

    if current_action.target_who == "player":
        effect.position = player_sprites.get_child(current_action.target_familiar).position
    else:
        effect.position = enemy_sprites.rect_position + enemy_sprites.get_child(1 - current_action.target_familiar).position

    effect.start()
