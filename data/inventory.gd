class_name Inventory

enum Category {
    POTION,
    GEMS
}

enum Item {
    POTION,
    HI_POTION,
    ETHER,
    RUBY,
    SAPPHIRE,
}

enum ItemUse {
    WORLD,
    BATTLE,
    BOTH
}

enum ItemAction {
    CHANGE_HEALTH,
    CHANGE_MANA,
    CAPTURE_MONSTER,
}

enum ItemTargets {
    ALLIES,
    ENEMIES
}

const ITEM_INFO = {
    Item.POTION: {
        "category": Category.POTION,
        "desc": "Heals a familiar by 20 HP",
        "use": ItemUse.BOTH,
        "action": ItemAction.CHANGE_HEALTH,
        "value": 20,
        "targets": ItemTargets.ALLIES,
    },
    Item.HI_POTION: {
        "category": Category.POTION,
        "desc": "Heals a familiar by 40 HP",
        "use": ItemUse.BOTH,
        "action": ItemAction.CHANGE_HEALTH,
        "value": 40,
        "targets": ItemTargets.ALLIES,
    },
    Item.ETHER: {
        "category": Category.POTION,
        "desc": "Restores a familiar's MP by 10",
        "use": ItemUse.BOTH,
        "action": ItemAction.CHANGE_MANA,
        "value": 20,
        "targets": ItemTargets.ALLIES,
    },
    Item.RUBY: {
        "category": Category.GEMS,
        "desc": "Captures a fire type monster",
        "use": ItemUse.BATTLE,
        "action": ItemAction.CAPTURE_MONSTER,
        "value": 0,
        "targets": ItemTargets.ENEMIES,
    },
    Item.SAPPHIRE: {
        "category": Category.GEMS,
        "desc": "Captures a water type monster",
        "use": ItemUse.BATTLE,
        "action": ItemAction.CAPTURE_MONSTER,
        "value": 0,
        "targets": ItemTargets.ENEMIES,
    },
}

var items = [[], []]

func item_id_at(category: int, index: int):
    return items[category][index].id

func item_name_at(category: int, index: int):
    return Item.keys()[item_id_at(category, index)]

func item_desc_at(category: int, index: int):
    return ITEM_INFO[item_id_at(category, index)].desc

func item_use_at(category: int, index: int):
    return ITEM_INFO[item_id_at(category, index)].use

func quantity_at(category: int, index: int):
    return items[category][index].quantity

func quantity_of(item: int):
    var category = ITEM_INFO[item].category
    for i in range(0, items[category].size()):
        if items[category][i].id == item:
            return items[category][i].quantity
    return 0

func size(category: int):
    return items[category].size()

func add_item(item: int, amount: int):
    var category = ITEM_INFO[item].category
    for _item in items[category]:
        if _item.id == item:
            _item.quantity += amount 
            return
    items[category].append({"id": item, "quantity": amount})

func remove_item(item: int, amount: int):
    var category = ITEM_INFO[item].category
    for i in range(0, items[category].size()):
        if items[category][i].id == item:
            items[category][i].quantity -= amount
            if items[category][i].quantity <= 0:
                items[category].remove(i)
            return

func swap_items(category: int, index_a: int, index_b: int):
    var temp_item = items[category][index_a].duplicate()
    items[category][index_a] = items[category][index_b].duplicate()
    items[category][index_b] = temp_item

func use_item(item: int, target: Familiar):
    # Use the item on the target
    var item_info = ITEM_INFO[item]
    if item_info.action == ItemAction.CHANGE_HEALTH:
        target.change_health(item_info.value)
    elif item_info.action == ItemAction.CHANGE_MANA:
        target.change_mana(item_info.value)
