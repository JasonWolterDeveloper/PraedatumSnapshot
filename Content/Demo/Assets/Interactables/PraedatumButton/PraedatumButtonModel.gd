class_name PraedatumButtonModel extends Node3D

@onready var can_activate_model : Node3D = $ScaleNode/PraedatumBasicButtonCanActivate
@onready var cannot_activate_model : Node3D = $ScaleNode/PraedatumBasicButtonCannotActivate
@onready var previously_activated_model : Node3D = $ScaleNode/PraedatumBasicButtonPreviouslyActivated


func show_can_activate():
	can_activate_model.show()
	cannot_activate_model.hide()
	previously_activated_model.hide()


func show_cannot_activate():
	can_activate_model.hide()
	cannot_activate_model.show()
	previously_activated_model.hide()


func show_previously_activated():
	can_activate_model.hide()
	cannot_activate_model.hide()
	previously_activated_model.show()
