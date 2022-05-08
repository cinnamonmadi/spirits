class_name Types

enum Type {
    FIRE,
    WATER,
    EARTH,
    AIR,
    NATURE,
    STORM,
    PLAGUE,
    ICE,
    NORMAL,
    MIND,
}

const TYPE_INFO = {
    Type.FIRE: {
        "weaknesses": [
            Type.WATER,
            Type.EARTH,
            Type.AIR,
            Type.MIND,
        ],
        "resistances": [
            Type.NATURE,
            Type.NORMAL,
            Type.PLAGUE,
            Type.ICE,
        ]
    },
    Type.WATER: {
        "weaknesses": [
            Type.NATURE,
            Type.PLAGUE,
            Type.STORM,
        ],
        "resistances": [
            Type.FIRE,
            Type.EARTH,
        ]
    },
    Type.EARTH: {
        "weaknesses": [
            Type.WATER,
            Type.NATURE,
        ],
        "resistances": [
            Type.FIRE,
            Type.AIR,
            Type.STORM,
        ]
    },
    Type.AIR: {
        "weaknesses": [
            Type.EARTH,
            Type.STORM
        ],
        "resistances": [
            Type.FIRE,
            Type.NATURE,
        ]
    },
    Type.NATURE: {
        "weaknesses": [
            Type.FIRE,
            Type.PLAGUE,
            Type.STORM,
            Type.ICE,
        ],
        "resistances": [
            Type.WATER,
            Type.EARTH,
            Type.MIND,
        ]
    },
    Type.STORM: {
        "weaknesses": [
            Type.EARTH
        ],
        "resistances": [
            Type.WATER,
            Type.AIR,
            Type.MIND,
        ]
    },
    Type.PLAGUE: {
        "weaknesses": [
            Type.FIRE,
            Type.MIND,
        ],
        "resistances": [
            Type.WATER,
            Type.NATURE,
            Type.NORMAL,
        ]
    },
    Type.ICE: {
        "weaknesses": [
            Type.FIRE,
            Type.MIND,
        ],
        "resistances": [
            Type.NATURE,
        ]
    },
    Type.NORMAL: {
        "weaknesses": [
            Type.FIRE,
            Type.PLAGUE,
        ],
        "resistances": []
    },
    Type.MIND: {
        "weaknesses": [
            Type.STORM,
            Type.FIRE,
            Type.NATURE,
        ],
        "resistances": [
            Type.PLAGUE,
        ]
    }
}

static func name_of(type: int):
    return Type.keys()[type]