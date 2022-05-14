class_name Conditions

static func new_condition(type: int):
    return load("res://data/conditions/" + Condition.Type.keys()[type].to_lower() +  ".gd").new()