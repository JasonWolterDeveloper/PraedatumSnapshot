class_name ImpactParticleEffect extends Node3D


@export var particle_producers : Array[GPUParticles3D]


func emit_particles():
	for my_particle_emitter : GPUParticles3D in particle_producers:
		my_particle_emitter.emitting = true
	$Lifetime.start()


func emit_particles_direction(particle_direction : Vector3):
	look_at(particle_direction)
	emit_particles()


func _on_lifetime_timeout():
	queue_free()
