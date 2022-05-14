extends Condition

func _init():
    type = Type.SPEED_BUFF
    reverse = Type.SPEED_DEBUFF
    duration_type = DurationType.EXTENDABLE

    success_message = "'s speed was raised!"
    failure_message = "'s speed is already raised!"
    expire_message = "'s speed returned to normal."
    extend_message = "'s speed buff was extended!"

func on_apply(familiar):
    familiar.speed_mod = 2.0

func on_remove(familiar):
    familiar.speed_mod = 1.0