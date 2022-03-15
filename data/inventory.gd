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
    EMERALD,
    ONYX,
    QUARTZ,
    RARE_RUBY,
    RARE_SAPPHIRE,
    RARE_EMERALD,
    RARE_ONYX,
    RARE_QUARTZ,
    PEARL,
    PEARL2,
    PEARL3,
    PEARL4,
    PEARL5,
    PEARL6,
    PEARL7,
    PEARL8,
    PEARL9,
}

enum ItemUse {
    WORLD,
    BATTLE,
    BOTH
}

const ITEM_INFO = {
    Item.POTION: {
        "category": Category.POTION,
        "desc": "Heals a familiar by 20 HP",
        "use": ItemUse.BOTH,
    },
    Item.HI_POTION: {
        "category": Category.POTION,
        "desc": "Heals a familiar by 40 HP",
        "use": ItemUse.BOTH,
    },
    Item.ETHER: {
        "category": Category.POTION,
        "desc": "Restores a familiar's MP by 10",
        "use": ItemUse.BOTH,
    },
    Item.RUBY: {
        "category": Category.GEMS,
        "desc": "Captures a fire type monster",
        "use": ItemUse.BATTLE,
    },
    Item.SAPPHIRE: {
        "category": Category.GEMS,
        "desc": "Captures a water type monster",
        "use": ItemUse.BATTLE,
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

func size(category: int):
    return items[category].size()

func add_item(item: int, amount: int):
    var category = ITEM_INFO[item].category
    for _item in items[category]:
        if _item.id == item:
            _item.quantity += category 
            return
    items[category].append({"id": item, "quantity": amount})

func remove_item(item: int, amount: int):
    var category = ITEM_INFO[item].category
    for i in range(0, items[category].size()):
        if items[category][i].id == item:
            items[category][i].quantity -= amount
            if items[category][i].quantity <= 0:
                items[category].erase(i)
            return

func swap_items(category: int, index_a: int, index_b: int):
    var temp_item = items[category][index_a].duplicate()
    items[category][index_a] = items[category][index_b].duplicate()
    items[category][index_b] = temp_item
