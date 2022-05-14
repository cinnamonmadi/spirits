extends Condition

func _init():
    type = Type.PARALYZED
    duration_type = DurationType.INDEFINITE

    success_message = " was paralyzed!"
    failure_message = " is already paralyzed!"
    expire_message = "was cured of its paralysis!"
    extend_message = ""

func on_perform_action(action, _familiar) -> String:
    if [Action.USE_MOVE, Action.REST].has(action.action):
        return " is paralyzed! It can't move!"
    else:
        return ""