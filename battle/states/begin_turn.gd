extends Node
class_name BeginTurn

onready var director = get_node("/root/Director")

const State = preload("res://battle/states/states.gd")
const Action = preload("res://battle/states/action.gd")

var current_familiar

func priority_of(action) -> int:
    if action.action == Action.RUN:
        return 20
    elif action.action == Action.USE_ITEM:
        return 19
    elif action.action == Action.SWITCH:
        return 18
    elif action.action == Action.USE_MOVE:
        return action.move.priority
    else:
        return 2

func action_sorter(a, b):
    if priority_of(a) > priority_of(b):
        return true
    elif priority_of(a) < priority_of(b):
        return false
    else:
        return get_parent().get_acting_familiar(a).get_speed() > get_parent().get_acting_familiar(b).get_speed()

func begin(_params):
    enemy_choose_actions()

    get_parent().actions.sort_custom(self, "action_sorter")
    
    get_parent().set_state(State.ANIMATE_MOVE, {})

func process(_delta):
    pass

func handle_tween_finish():
    pass

func handle_timer_timeout():
    pass

func enemy_choose_actions():
    for i in range(0, min(director.enemy_party.familiars.size(), 2)):
        if not director.enemy_party.familiars[i].is_living():
            continue
        enemy_choose_action(i)

func move_sorter(a, b):
    if a.preference >= b.preference:
        return true
    else: 
        return false

func enemy_choose_action(enemy_index: int):
    var enemy = director.enemy_party.familiars[enemy_index]

    var target_index
    if not director.player_party.familiars[0].is_living():
        target_index = 1
    elif not director.player_party.familiars[1].is_living():
        target_index = 0
    else:
        target_index = director.rng.randi_range(0, 1)
    var target = director.player_party.familiars[target_index]

    var preferred_prudence_weights = []
    preferred_prudence_weights.append((enemy.health / enemy.max_health) * 5)
    preferred_prudence_weights.append((target.health / target.max_health) * 5)

    # Prudence by level difference
    var level_difference = enemy.get_level() - target.get_level()
    if level_difference == 0:
        preferred_prudence_weights.append(3)
    elif level_difference > 0: 
        if level_difference <= 3:
            preferred_prudence_weights.append(2)
        else:
            preferred_prudence_weights.append(1)
    else:
        if level_difference >= -3:
            preferred_prudence_weights.append(4)
        else:
            preferred_prudence_weights.append(5)

    var total_prudence = 0
    for prudence in preferred_prudence_weights:
        total_prudence += prudence
    var preferred_prudence = total_prudence / preferred_prudence_weights.size()

    # Find the difference in prudence for each move
    var move_prudence_difference = []
    var unique_prudence_differences = []
    for move in enemy.moves:
        var ignore_this_move = false
        # Check to make sure target does not already have the move's condition
        if move.power == 0:
            var target_has_conditions = false
            for condition in move.conditions:
                if target.has_condition(condition):
                    target_has_conditions = true
                    break
            if target_has_conditions:
                ignore_this_move = true
        # Check to make sure the enemy has enough mana
        if move.cost > enemy.mana:
            ignore_this_move = true

        if ignore_this_move:
            move_prudence_difference.append(-1)
            continue

        var prudence_difference = abs(preferred_prudence - move.prudence)
        move_prudence_difference.append(prudence_difference)
        if not unique_prudence_differences.has(prudence_difference):
            unique_prudence_differences.append(prudence_difference)
    
    # Swap the values so that moves with lower prudence have a higher preference
    unique_prudence_differences.sort()
    var move_preferences = []
    var sum_of_move_preferences = 0
    for i in range(0, move_prudence_difference.size()):
        if move_prudence_difference[i] == -1:
            move_preferences.append(-1)
            continue

        var index_of_value = (unique_prudence_differences.size() - 1) - unique_prudence_differences.find(move_prudence_difference[i])
        var move_preference = unique_prudence_differences[index_of_value]

        move_preferences.append(move_preference)
        sum_of_move_preferences += move_preference

    # Sort the moves with their preferences
    var moves_with_preferences = []
    for i in range(0, enemy.moves.size()):
        if move_preferences[i] == -1:
            continue
        moves_with_preferences.append({
            "move": enemy.moves[i],
            "preference": move_preferences[i],
        })
    moves_with_preferences.sort_custom(self, "move_sorter")

    # If there's no moves to chose, then rest
    if moves_with_preferences.size() == 0:
        get_parent().actions.append({
            "who": "enemy",
            "familiar": enemy_index,
            "action": Action.REST,
        })
        return

    # Choose the move with rng
    var move_rng_value = director.rng.randi_range(1, sum_of_move_preferences)
    var rng_threshold = 0
    var chosen_move = null
    for move in moves_with_preferences:
        rng_threshold += move.preference
        if move_rng_value <= rng_threshold:
            chosen_move = move.move
            break
    if chosen_move == null:
        print("Error! Chosen move was null in begin_turn.enemy_choose_action")

    # Add the action to the actions screen
    get_parent().actions.append({
        "who": "enemy",
        "familiar": enemy_index,
        "action": Action.USE_MOVE,
        "move": chosen_move,
        "target_who": "player",
        "target_familiar": target_index
    })
