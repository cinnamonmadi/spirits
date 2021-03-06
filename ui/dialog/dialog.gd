extends NinePatchRect

onready var rows = get_children()

enum State {
    CLOSED,
    READING,
    WAITING
}

var ROW_CHAR_LEN: int = 36
var DIALOG_SPEED: float = (4 / 60.0)

var lines = []
var current_line = []
var current_row = 0
var next_char_timer: float
var wait_timer: float = -1

var state = State.CLOSED
var keep_open = false

func _ready():
    hide()

func hide():
    if keep_open:
        rows[0].text = ""
        rows[1].text = ""
    else:
        visible = false

func is_open() -> bool:
    return state != State.CLOSED

func is_waiting() -> bool:
    return state == State.WAITING

func create_empty_line():
    var empty_line = []
    for row in rows:
        empty_line.append("")
    return empty_line

func load_lines(text: String):
    lines = []
    var words = text.split(" ")
    var next_line = create_empty_line()
    var next_line_row = 0

    while words.size() != 0:
        var next_word = words[0]
        words.remove(0)
        # Check if the word has a newline at the end of it
        var endline_after_word = next_word.ends_with("\n")
        if endline_after_word:
            # Remove the newline character so we don't add it to the rows
            next_word = next_word.substr(0, next_word.find("\n"))
        # Add a space between words if needed
        if next_line[next_line_row].length() != 0:
            next_word = " " + next_word

        # Check if there's enough space to insert the word
        var space_left_in_row = ROW_CHAR_LEN - next_line[next_line_row].length()
        if space_left_in_row < next_word.length():
            # Increment rows
            if next_line_row < rows.size() - 1:
                next_line_row += 1
            else:
                lines.append(next_line)
                next_line = create_empty_line()
                next_line_row = 0
            # If we added a space before, remove it since we're going to the next line
            if next_word[0] ==  " ":
                next_word = next_word.substr(1)

        # Insert the word
        next_line[next_line_row] += next_word

        # And finally, if we had a newline in the word, that means we should end this line here
        if endline_after_word:
            lines.append(next_line)
            next_line = create_empty_line()
            next_line_row = 0
    if next_line[0] != "":
        lines.append(next_line)

func _open():
    pop_next_line()
    visible = true
    state = State.READING

func open_with(set_lines):
    lines = set_lines
    wait_timer = -1
    _open()

func open(text: String):
    load_lines(text)
    wait_timer = -1
    _open()

func open_and_wait(text: String, duration: float):
    open(text)
    wait_timer = duration

func open_empty():
    for row in rows:
        row.text = ""
    visible = true
    state = State.WAITING

func close():
    hide()
    state = State.CLOSED

func pop_next_line():
    current_line = lines[0]
    lines.remove(0)
    current_row = 0
    start_next_char_timer()
    for row in rows:
        row.text = ""

func start_next_char_timer():
    next_char_timer = DIALOG_SPEED

func add_next_char():
    rows[current_row].text += current_line[current_row][0]
    current_line[current_row] = current_line[current_row].substr(1)

# Called when the user presses the action button on the dialog
func progress():
    if state == State.CLOSED:
        return
    if state == State.WAITING:
        if lines.size() == 0:
            close()
        else:
            pop_next_line()
            state = State.READING
    elif state == State.READING:
        # Read the rest of the line
        for i in range(current_row, rows.size()):
            rows[i].text += current_line[i]
        state = State.WAITING

func _process(delta):
    if state == State.CLOSED:
        return
    elif state == State.WAITING:
        if wait_timer == -1:
            return
        wait_timer -= delta
        if wait_timer <= 0:
            wait_timer = -1
            close()
    elif state == State.READING:
        # Decrement the dialog timer
        next_char_timer -= delta
        if next_char_timer <= 0:
            add_next_char()
            while state != State.WAITING and current_line[current_row].length() == 0:
                if current_row < rows.size() - 1:
                    current_row += 1
                else:
                    state = State.WAITING
            if state != State.WAITING:
                start_next_char_timer()
