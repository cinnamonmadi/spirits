extends Node

enum Effect {
    ITEM,
    MONSTER_DEATH,
}

const EFFECT_INFO = {
    Effect.ITEM: {
        "frames": 8,
        "fps": 8,
    },
    Effect.MONSTER_DEATH: {
        "frames": 12,
        "fps": 10,
    }
}

const effect_scene = preload("res://battle/effects/effect.tscn")

func create_effect(effect: int):
    var effect_instance = effect_scene.instance()
    effect_instance.setup("res://battle/effects/" + Effect.keys()[effect] + ".png", EFFECT_INFO[effect].frames, EFFECT_INFO[effect].fps)
    return effect_instance
