extends Condition

func _init():
    type = Type.FOCUS_DEBUFF
    reverse = Type.FOCUS_BUFF
    duration_type = DurationType.EXTENDABLE

    success_message = "'s focus was lowered!"
    failure_message = "'s focus is already lowered!"
    expire_message = "'s focus returned to normal."
    extend_message = "'s focus debuff was extended!"

func on_apply(familiar):
    familiar.focus_mod = 0.5

func on_remove(familiar):
    familiar.focus_mod = 1.0