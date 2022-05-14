extends Condition

func config():
    type = Type.TRAPPED
    reverse = Type.NONE
    duration_type = DurationType.INDEFINITE

    success_message = ""
    failure_message = ""
    expire_message = ""
    extend_message = ""

func on_perform_action(action, familiar):
    if [Action.USE_MOVE, Action.SWITCH, Action.REST].has(action.action):
        return {
            "type": ResponseType.INTERRUPT,
            "message": " is trapped! It can't move!"
        }
    else:
        return .on_perform_action(action, familiar)