extends Condition

func _init():
    type = Type.SPEED_DEBUFF
    reverse = Type.SPEED_BUFF
    duration_type = DurationType.EXTENDABLE

    success_message = "'s speed was lowered!"
    failure_message = "'s speed is already lowered!"
    expire_message = "'s speed returned to normal."
    extend_message = "'s speed debuff was extended!"

func on_apply(familiar):
    familiar.speed_mod = 0.5

func on_remove(familiar):
    familiar.speed_mod = 1.0