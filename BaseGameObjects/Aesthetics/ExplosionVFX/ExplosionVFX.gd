class_name ExplosionVFX extends Node3D

@onready var sparks : GPUParticles3D = $Sparks
@onready var flash : GPUParticles3D = $Flash
@onready var fire : GPUParticles3D = $Fire
@onready var smoke : GPUParticles3D = $Smoke

@onready var particle_emitters : Array[GPUParticles3D] =[sparks, flash, fire, smoke]

@export var explosion_length_scale = 1.0


func _ready():
	for particle_emitter in particle_emitters:
		particle_emitter.lifetime = particle_emitter.lifetime * explosion_length_scale
	

func play_vfx():
	sparks.emitting = true
	flash.emitting = true
	fire.emitting = true
	smoke.emitting = true
