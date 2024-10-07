extends TriggerInteractableObject

@onready var computer_on_model : Node3D = $InteractableComputerOn
@onready var computer_off_model : Node3D = $InteractableComputerOff
@onready var computer_locked_model : Node3D = $InteractableComputerLocked


func _ready():
	super()
	update_aesthetics()


func update_aesthetics():
	super()
	update_computer_model()


func update_computer_model():
	if can_activate(get_player()):
		computer_on_model.show()
		computer_off_model.hide()
		computer_locked_model.hide()
	else: # has_been_activated and not allow_if_activated:
		computer_on_model.hide()
		computer_off_model.show()
		computer_locked_model.hide()
	"""
	else:
		computer_on_model.hide()
		computer_off_model.hide()
		computer_locked_model.show()
	"""
