class_name Party

var familiars = []

func get_living_familiar_count() -> int:
    var count = 0
    for familiar in familiars:
        if familiar.is_living():
            count += 1
    return count

func is_wiped() -> bool:
    return get_living_familiar_count() == 0

func swap_familiars(a: int, b: int):
    var temp = familiars[a]
    familiars[a] = familiars[b]
    familiars[b] = temp

func sort_fighters_first():
    if not familiars[0].is_living():
        for i in range(1, familiars.size()):
            if familiars[i].is_living():
                swap_familiars(0, i)
                break
    if not familiars[1].is_living():
        for i in range(2, familiars.size()):
            if familiars[i].is_living():
                swap_familiars(1, i)
                break