class_name SpentRound extends RigidBody3D

## Abstract class for ejected casings

@export var expiration_time:float = 3 ## Number of seconds till the spent round is deleted

@onready var timer:Timer = $Timer

var casing_sound:AudioStreamPlayer3D


func _ready():
	timer.start(expiration_time)
	for child in get_children():
		if child is AudioStreamPlayer3D:
			casing_sound = child


func _on_timer_timeout():
	queue_free()


func _on_body_entered(body):
	if casing_sound:
		casing_sound.play()
