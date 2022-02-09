extends ColorRect

const FLASH_FREQUENCY: float = 0.2
const FLASH_COUNT: int = 6

var timer: float = FLASH_FREQUENCY
var counter: int = FLASH_COUNT
var finished: bool = false

func _ready():
    pass 

func _process(delta):
    if finished:
        return
    timer -= delta
    if timer <= 0:
        counter -= 1
        if counter <= 0:
            finished = true
        visible = not visible
        timer = FLASH_FREQUENCY