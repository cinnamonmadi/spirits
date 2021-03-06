extends Condition

func config():
    type = Type.PARALYZED
    duration_type = DurationType.INDEFINITE

    success_message = " was paralyzed!"
    failure_message = " is already paralyzed!"
    expire_message = "was cured of its paralysis!"
    extend_message = ""

func on_perform_action(action, familiar):
    if [Action.USE_MOVE, Action.REST].has(action.action):
        return {
            "type": ResponseType.INTERRUPT,
            "message": " is paralyzed! It can't move!"
        }
    else:
        return .on_perform_action(action, familiar)