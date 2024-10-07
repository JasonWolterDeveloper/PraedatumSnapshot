class_name EnemyGibs extends Node3D

const DEFAULT_FORCE_DIRECTION = Vector3(0, 0.8, 1)
const DEFAULT_FORCE_INTENSITY = 200.0

@export var physics_force_random_low_value : float = 1.0
@export var physics_force_random_high_value : float = 1.0

@onready var explosion_vfx : ExplosionVFX = $ExplosionVFX

# func _ready():
# 	apply_physics_gibs()


func apply_physics_gibs(direction_vector : Vector3 = DEFAULT_FORCE_DIRECTION, intensity : float = DEFAULT_FORCE_INTENSITY):
	$DisappearTimer.start()
	for my_child in get_children():
		if my_child is RigidBody3D:
			var random_multiplier = 1.0
			if physics_force_random_low_value != physics_force_random_high_value:
				random_multiplier = randf_range(physics_force_random_low_value, physics_force_random_high_value)
			my_child.apply_central_force(my_child.to_global(direction_vector * random_multiplier * intensity))
	explosion_vfx.play_vfx()


func _on_disappear_timer_timeout():
	queue_free()
	pass # Replace with function body.
