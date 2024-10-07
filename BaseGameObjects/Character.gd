class_name Character extends CharacterBody3D

signal died

@export var delete_on_death = true
@export var time_between_shots = 0.12
@export var display_name : String = ""
@export var stun_aesthetic_effect : GPUParticles3D
@export var rpg_tags: RPGTags = null
@export var status_effect_text_scene:PackedScene ## StatusEffectDisplay scene

var dead = false
var stunned :
	get : return rpg_mechanics_master.is_stunned()
var cam_accel = 40
var mouse_sense = 0.1
var snap
var angular_velocity = 30
var trigger_down = false
var time_since_last_shot = 0
var current_room : Room
var armour:Armour:
	get: return get_armour()

@onready var aiming_master := $LookStuff/AimingMaster
@onready var movement_master := $MovementMaster
@onready var rpg_mechanics_master : RPGMechanicsMaster = $RPGMechanicsMaster
@onready var animation_player := $LookStuff/AnimationPlayer
@onready var projectile_hitbox := $ProjectileHitbox
@onready var status_effect_text_marker := $StatusEffectTextMarker

func _ready():
	child_set_my_character(self)

	#hides the cursor
	# Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#mesh no longer inherits rotation of parent, allowing it to rotate freely
	# mesh.set_as_toplevel(true)


# Called when a character dies. May be extended by characters who have special
# functions on death, such as the player.
func on_death():
	dead = true
	emit_signal("died")
	if delete_on_death:
		queue_free()
	
	
func face_aim_point():
	$LookStuff.look_at(aiming_master.aim_point, Vector3.UP)
	
	
func is_moving():
	return movement_master.is_moving()
	

"""
func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
"""


func generate_miss_bullet_endpoint():
	return aiming_master.generate_missed_bullet_endpoint()


func _process(delta):
	
	# TEST:
	if Input.is_action_just_pressed("debug_1"):
		display_status_effect_text("Dumbass")
	
	"""
	#physics interpolation to reduce jitter on high refresh-rate monitors
	var fps = Engine.get_frames_per_second()
	if fps > Engine.iterations_per_second:
		campivot.set_as_toplevel(true)
		campivot.global_transform.origin = campivot.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		campivot.rotation.y = rotation.y
		campivot.rotation.x = head.rotation.x
		mesh.global_transform.origin = mesh.global_transform.origin.linear_interpolate(global_transform.origin, cam_accel * delta)
	else:
		campivot.set_as_toplevel(false)
		campivot.global_transform = head.global_transform
		mesh.global_transform.origin = global_transform.origin
	"""

	"""
	#turns body in the direction of movement
	if direction != Vector3.ZERO:
		mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(-direction.x, -direction.z), angular_velocity * delta)
		
	"""
	

func entered_room(room : Room):
	current_room = room


func exited_room(room : Room):
	pass


func show_stun_status_effect():
	if stun_aesthetic_effect:
		stun_aesthetic_effect.show()


func hide_stun_status_effect():
	if stun_aesthetic_effect:
		stun_aesthetic_effect.hide()


## Simply spawns a StatusEffectDisplay object at the corresponding marker. Ensure the marker is in a 
## visble location on the character.
func display_status_effect_text(text:String, duration:float = 1.5) -> void:
	assert(status_effect_text_scene and status_effect_text_marker)
	if status_effect_text_scene:
		var status_effect_text := status_effect_text_scene.instantiate()
		status_effect_text.lifetime = duration
		status_effect_text.text = text
		status_effect_text.position = status_effect_text_marker.position
		add_child(status_effect_text)


# Recursively assigns childrens' pointers to this character
func child_set_my_character(current_node):
	if current_node.has_method("set_my_character"):
		current_node.set_my_character(self)
		
	for child in current_node.get_children():
		child_set_my_character(child)


func _to_string():
	return name + ""


## Abstract funciton
func get_armour() -> Armour:
	return null
