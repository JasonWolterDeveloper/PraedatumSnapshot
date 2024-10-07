class_name LevelTransitionDoor extends LevelTransitionInteractable


@export var locked : bool = false
@export var unlock_conditions : Array[ConditionEvaluator] = []

# ----- Child Refs ----- #
@export var locked_aesthetics : Node3D
@export var unlocked_aesthetics : Node3D



# -------- Ready and Assignment Functions --------- #

func _ready() -> void:
	if check_should_unlock():
		unlock()
	update_aesthetics()


## Checks if we should unlock the door based on current conditiohs. Usually done at the start of a
## raid
func check_should_unlock():
	for my_condition : ConditionEvaluator in unlock_conditions:
		if not my_condition.evaluate():
			return false
	return true



# ---------- Use Functions --------- #


func can_unlock():
	return false


func can_activate(activator : Character):
	if locked:
		return can_unlock() and super(activator)
	else:
		return super(activator)


func unlock():
	locked = false
	update_aesthetics()


func activate(activator : Character):
	if locked:
		unlock()
	else:
		super(activator)



# ---------- Aesthetics -------- #


func show_locked_aesthetics():
	if locked_aesthetics:
		locked_aesthetics.show()
	if unlocked_aesthetics:
		unlocked_aesthetics.hide()


func show_unlocked_aesthetics():
	if locked_aesthetics:
		locked_aesthetics.hide()
	if unlocked_aesthetics:
		unlocked_aesthetics.show()


func update_aesthetics():
	super()
	if locked:
		show_locked_aesthetics()
	else:
		show_unlocked_aesthetics()
