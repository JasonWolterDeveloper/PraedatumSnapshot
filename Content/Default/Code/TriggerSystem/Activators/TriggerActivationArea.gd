class_name TriggerActivationArea extends Area3D

# ----- Parameters ----- #
@export var trigger_id : String = ""
@export var player_activates : bool = true
@export var enemy_activates : bool = false


func _on_body_entered(body: Node3D) -> void:
	var trigger : Trigger = TriggerMaster.get_trigger_by_id(trigger_id)
	
	if is_instance_valid(trigger):
		if player_activates:
			if body is Player:
				trigger.activate()
		if enemy_activates:
			if body is Enemy:
				trigger.activate()
