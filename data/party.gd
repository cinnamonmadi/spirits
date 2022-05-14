class_name Party

var familiars = []
var old_familiar_order = []
var in_battle = false

func get_living_familiar_count() -> int:
    var count = 0
    for familiar in familiars:
        if familiar.is_living():
            count += 1
    return count

func is_wiped() -> bool:
    return get_living_familiar_count() == 0

func add_familiar(familiar: Familiar):
    familiars.append(familiar)

func pre_battle_setup():
    # Remember old familiar order
    old_familiar_order = []
    for i in range(0, familiars.size()):
        old_familiar_order.append(familiars[i])
        familiars[i].is_resting = false
        familiars[i].participated = false
        familiars[i].is_burnedout = false

    sort_fighters_first()

    # Set first two fighters as having participated
    for i in range(0, min(familiars.size(), 2)):
        familiars[i].participated = true

    in_battle = true

func recall_familiar_order():
    familiars = []
    for i in range(0, old_familiar_order.size()):
        familiars.append(old_familiar_order[i])

func post_battle_setup():
    recall_familiar_order()
    for familiar in familiars:
        familiar.is_resting = false
        familiar.participated = false
        familiar.is_burnedout = false
        familiar.mana = familiar.max_mana
        familiar.clear_temporary_conditions()

    in_battle = false

func swap_familiars(a: int, b: int):
    if in_battle:
        if a == 0 or a == 1:
            familiars[a].clear_temporary_conditions()
        elif b == 0 or b == 1:
            familiars[b].clear_temporary_conditions()

    var temp = familiars[a]
    familiars[a] = familiars[b]
    familiars[b] = temp

    if in_battle:
        for i in range(0, min(familiars.size(), 2)):
            if familiars[i].is_living():
                familiars[i].participated = true

func sort_fighters_first():
    if not familiars[0].is_living():
        for i in range(1, familiars.size()):
            if familiars[i].is_living():
                swap_familiars(0, i)
                break
    if familiars.size() == 1:
        return
    if not familiars[1].is_living():
        for i in range(2, familiars.size()):
            if familiars[i].is_living():
                swap_familiars(1, i)
                break
