extends Sprite
class_name FamiliarSprite

enum Animation {
    ENTER,
    IDLE,
    LOW,
    ATTACK,
    STUN,
    DEATH
}

const ANIM_INFO = {
    Animation.ENTER: {
        "start": 1,
        "end": 1,
    },
    Animation.IDLE: {
        "start": 2,
        "end": 3,
    },
    Animation.LOW: {
        "start": 4,
        "end": 5,
    },
    Animation.ATTACK: {
        "start": 6,
        "end": 6,
    },
    Animation.STUN: {
        "start": 7,
        "end": 7,
    },
    Animation.DEATH: {
        "start": 8,
        "end": 8,
    }
}

const FRAME_DURATION = 0.5

var familiar: Familiar = null
var animation = Animation.IDLE
var timer 
var is_playing = false

func _ready():
    pass 

func config(with_familiar: Familiar, is_player: bool):
    familiar = with_familiar
    texture = load("res://battle/familiars/" + familiar.species.name.to_lower() + ".png")
    if is_player:
        frame_coords.y = 1
    else:
        frame_coords.y = 0
    frame_coords.x = 0

func start_animation(animation_to_play: int):
    animation = animation_to_play
    timer = FRAME_DURATION
    frame_coords.x = ANIM_INFO[animation].start
    is_playing = true

func _process(delta):
    if not is_playing:
        return
    if familiar.health == 0:
        start_animation(Animation.DEATH)
    timer -= delta
    if timer <= 0:
        if frame_coords.x != ANIM_INFO[animation].end:
            frame_coords.x += 1
            timer += FRAME_DURATION
        else:
            _on_animation_finish()

func _on_animation_finish():
    if familiar.health == 0:
        return
    elif familiar.health > 0.25 * familiar.max_health:
        start_animation(Animation.IDLE)
    else:
        start_animation(Animation.LOW)
