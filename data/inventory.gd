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

const ITEM_INFO = {
    Item.POTION: {
        "category": Category.POTION,
        "desc": "Heals a familiar by 20 HP"
    },
    Item.HI_POTION: {
        "category": Category.POTION,
        "desc": "Heals a familiar by 40 HP"
    },
    Item.ETHER: {
        "category": Category.POTION,
        "desc": "Restores a familiar's MP by 10"
    },
    Item.RUBY: {
        "category": Category.GEMS,
        "desc": "Captures a fire type monster"
    },
    Item.SAPPHIRE: {
        "category": Category.GEMS,
        "desc": "Captures a water type monster"
    },
    Item.EMERALD: {
        "category": Category.GEMS,
        "desc": "Captures a grass type monster"
    },
    Item.ONYX: {
        "category": Category.GEMS,
        "desc": "Captures a rock type monster"
    },
    Item.QUARTZ: {
        "category": Category.GEMS,
        "desc": "Captures a ghost type monster"
    },
    Item.RARE_RUBY: {
        "category": Category.GEMS,
        "desc": "Captures a fire type monster really well"
    },
    Item.RARE_SAPPHIRE: {
        "category": Category.GEMS,
        "desc": "Captures a water type monster really well"
    },
    Item.RARE_EMERALD: {
        "category": Category.GEMS,
        "desc": "Captures a grass type monster really well"
    },
    Item.RARE_ONYX: {
        "category": Category.GEMS,
        "desc": "Captures a rock type monster really well"
    },
    Item.RARE_QUARTZ: {
        "category": Category.GEMS,
        "desc": "Captures a ghost type monster really well"
    },
    Item.PEARL: {
        "category": Category.GEMS,
        "desc": "Captures a monster of any type"
    },
    Item.PEARL2: {
        "category": Category.GEMS,
        "desc": "Captures a monster of any type"
    },
    Item.PEARL3: {
        "category": Category.GEMS,
        "desc": "Captures a monster of any type"
    },
    Item.PEARL4: {
        "category": Category.GEMS,
        "desc": "Captures a monster of any type"
    },
    Item.PEARL5: {
        "category": Category.GEMS,
        "desc": "Captures a monster of any type"
    },
    Item.PEARL6: {
        "category": Category.GEMS,
        "desc": "Captures a monster of any type"
    },
    Item.PEARL7: {
        "category": Category.GEMS,
        "desc": "Captures a monster of any type"
    },
    Item.PEARL8: {
        "category": Category.GEMS,
        "desc": "Captures a monster of any type"
    },
    Item.PEARL9: {
        "category": Category.GEMS,
        "desc": "Captures a monster of any type"
    },
}

var items = [[], []]

func item_id_at(category: int, index: int):
    return items[category][index].id

func item_name_at(category: int, index: int):
    return Item.keys()[item_id_at(category, index)]

func item_desc_at(category: int, index: int):
    return ITEM_INFO[item_id_at(category, index)].desc

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
