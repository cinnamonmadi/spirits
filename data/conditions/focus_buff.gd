extends Condition

func _init():
    type = Type.FOCUS_BUFF
    reverse = Type.FOCUS_DEBUFF
    duration_type = DurationType.EXTENDABLE

    success_message = "'s focus was raised!"
    failure_message = "'s focus is already raised!"
    expire_message = "'s focus returned to normal."
    extend_message = "'s focus buff was extended!"

func on_apply(familiar):
    familiar.focus_mod = 2.0

func on_remove(familiar):
    familiar.focus_mod = 1.0