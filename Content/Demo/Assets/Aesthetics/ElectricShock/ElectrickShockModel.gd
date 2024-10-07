class_name ElectricShockModel extends Node3D

@onready var timer : Timer = $Timer
@onready var lightning_mesh : MeshInstance3D = $LightningPlane
@export var duration : float = 0.2


func _ready():
	timer.wait_time = duration


func play_eletric_shock_animation_toward_point(point : Vector3):
	# Removing the y component from point
	var look_at_point = Vector3(point.x, global_position.y, point.z)
	look_at(look_at_point, Vector3.UP)
	lightning_mesh.show()
	timer.start()


func _on_timer_timeout():
	lightning_mesh.hide()
	pass # Replace with function body.
