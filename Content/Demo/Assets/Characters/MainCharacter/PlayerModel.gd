class_name PlayerModel extends Node3D

const WEAPON_MESH_NAME = "weapon_mesh"

enum {RIFLE_POSE, PISTOL_POSE}

# ---------- Animation Tree References ---------- #
const PISTOL_LOCOMOTION_PATH = "parameters/Pistol/PistolLocomotion/blend_position"
const RIFLE_LOCOMOTION_PATH = "parameters/Rifle/RifleLocomotion/blend_position"
const UNARMED_LOCOMOTION_PATH = "parameters/Unarmed/UnarmedLocomotion/blend_position"
const MELEE_LOCOMOTION_PATH = "parameters/Melee/MeleeLocomotion/blend_position"

const UNARMED_STATE = "Unarmed"
const MELEE_STATE = "Melee"
const RIFLE_STATE = "Rifle"
const PISTOL_STATE = "Pistol"

@export var animation_tree : AnimationTree
var main_playback : AnimationNodeStateMachinePlayback
var melee_upper_body_playback : AnimationNodeStateMachinePlayback

# ----------- Weapon Container and Mesh References ---------- #
var weapon_mesh : Node3D
var rifle_container : Node3D
var pistol_container : Node3D
var melee_container : Node3D



# ---------- Ready and Assignment Functions ---------- #


func _ready():
	rifle_container = Util.find_node_by_name(self, "RifleContainer")
	pistol_container = Util.find_node_by_name(self, "PistolContainer")
	melee_container = Util.find_node_by_name(self, "MeleeContainer")
	
	main_playback = animation_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
	melee_upper_body_playback = animation_tree.get("parameters/Melee/MeleeUpperBody/playback") as AnimationNodeStateMachinePlayback



# ---------- Update Functions ---------- #


# set our moment direction relative to the direction we are facing
func set_movement_direction(movement_direction : Vector3):
	var local_movement_direction = to_local(movement_direction)
	var local_movement_direction_vertical_component_removed = Vector2(local_movement_direction.x, 
																	  local_movement_direction.z)
	var final_normalized_value = local_movement_direction_vertical_component_removed.normalized()
	set_all_locomotion_values(final_normalized_value)



# ---------- Animation State Functions ---------- #


func enter_unarmed_state():
	main_playback.travel(UNARMED_STATE)


func enter_rifle_state():
	main_playback.travel(RIFLE_STATE)


func enter_pistol_state():
	main_playback.travel(PISTOL_STATE)


func enter_melee_state():
	main_playback.travel(MELEE_STATE)



# ---------- Specific Animation Functions ---------- #


func play_melee_swing():
	if melee_upper_body_playback:
		melee_upper_body_playback.travel("MeleeStrike")



# ---------- Weapon Mesh Functions ---------- #


# Removes any and all weapon_meshes that might be on the Player Model
func remove_weapon_mesh():
	if is_instance_valid(weapon_mesh):
		if weapon_mesh.get_parent():
			weapon_mesh.get_parent().remove_child(weapon_mesh)
		weapon_mesh.queue_free()


func add_weapon_mesh(new_weapon_mesh : Node3D, weapon_type : String = "pistol"):
	# Ensure we do not have a pre-existing weapon mesh, so that we are guaranteed
	# to only ever have one weapon mesh on the player model, which is important
	remove_weapon_mesh()
	
	weapon_mesh = new_weapon_mesh
	weapon_mesh.name = WEAPON_MESH_NAME
	
	if weapon_type == "pistol":
		pistol_container.add_child(weapon_mesh)
	if weapon_type == "rifle":
		rifle_container.add_child(weapon_mesh)
	if weapon_type == "melee":
		melee_container.add_child(weapon_mesh)



# ----------- Getters and Setters ----------- #


func set_all_locomotion_values(locomotion_value : Vector2) -> void:
	animation_tree.set(UNARMED_LOCOMOTION_PATH, locomotion_value)
	animation_tree.set(RIFLE_LOCOMOTION_PATH, locomotion_value)
	animation_tree.set(PISTOL_LOCOMOTION_PATH, locomotion_value)
	animation_tree.set(MELEE_LOCOMOTION_PATH, locomotion_value)


func get_weapon_mesh():
	if is_instance_valid(weapon_mesh):
		return weapon_mesh
	return null
