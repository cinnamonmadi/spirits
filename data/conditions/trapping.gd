extends Condition

var trapped_familiar
var familiar_old_moves 

func config():
    type = Type.TRAPPING
    reverse = Type.NONE
    duration_type = DurationType.INDEFINITE

    success_message = ""
    failure_message = ""
    expire_message = ""
    extend_message = ""

func on_apply(params, familiar):
    trapped_familiar = params.trapped_familiar

    familiar_old_moves = familiar.moves
    familiar.moves = [load("res://data/moves/idle.tres"), load("res://data/moves/trap_release.tres")]
    print(familiar_old_moves)

func on_remove(familiar):
    for condition in trapped_familiar.conditions:
        if condition.type == Type.TRAPPED:
            trapped_familiar.remove_condition(condition)
            break

    familiar.moves = familiar_old_moves

func on_perform_action(action, familiar):
    if action.action == Action.REST:
        return {
            "type": ResponseType.INTERRUPT,
            "message": " can't rest! It's trapping a foe!"
        }
    elif action.action == Action.SWITCH:
        return {
            "type": ResponseType.INTERRUPT,
            "message": " can't switch out! It's trapping a foe!"
        }
    else:
        return .on_perform_action(action, familiar)

func on_attacked(attacker, familiar, move):
    if move.power == 0:
        return .on_attacked(attacker, familiar, move)
    familiar.remove_condition(self)
    return {
        "type": ResponseType.NONE,
        "message": " released " + trapped_familiar.get_display_name() + "!"
    }