class_name Explosion extends Area3D

# const DAMAGE_EVENT = preload("res://Content/RPGMechanics/Events/DamageEvent.tscn")

@export var damage = 60.0
@export var radius : float = 5.0
@onready var sprite = $AnimatedSprite2D
@export var explosion_vfx : ExplosionVFX
@export var door_damage_strength : int = 0
var exploded = false

var explosion_creator : Character = null

@export var time_to_explode = 1.0
var current_time = 0.0

signal explosion_finished


func explode():
	exploded = true
	if explosion_vfx:
		explosion_vfx.play_vfx()
	for my_body in get_overlapping_bodies():
		if my_body is Character:
			DebugMaster.log_debug(my_body)
			if Util.check_los_to_object(self, my_body):
				apply_to_character(my_body)
		if my_body is Door:
			apply_to_door(my_body)


func apply_to_door(door : Door):
	if door_damage_strength > 0:
		door.attempt_to_destroy_by_explosion(self)


func apply_to_character(character : Character):
	# DebugMaster.log_debug("Hit this Character with explosion: " + str(character.name))
	if damage > 0:
		RPGEventMaster.invoke_damage_event(damage, character, explosion_creator)


func _process(delta):
	if exploded:
		current_time += delta
	if current_time > time_to_explode:
		emit_signal("explosion_finished")
