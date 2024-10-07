class_name WeaponModel extends Node3D

@export var muzzle_flash_time :float = 0.07
var current_muzzle_flash_time : float = 0
var playing_muzzle_flash : bool = false

var bullet_start_pos_marker : Marker3D
var laser_pos_marker : Marker3D

@export var muzzle_flash : MeshInstance3D
var muzzle_flash_light : OmniLight3D

var slide_mesh : MeshInstance3D

var slide_base_position : Node3D
var slide_back_position : Node3D

var weapon : Weapon = null

func _ready():
	bullet_start_pos_marker = Util.find_node_by_name(self, "BulletStartPos")
	laser_pos_marker = Util.find_node_by_name(self, "LaserPos")
	
	if not muzzle_flash:
		muzzle_flash = Util.find_node_by_name(self, "MuzzleFlash")
	muzzle_flash_light = Util.find_node_by_name(self, "MuzzleFlashLight")
	
	
	slide_mesh = Util.find_node_by_name(self, "Slide")
	slide_base_position = Util.find_node_by_name(self, "SlideBasePosition")
	slide_back_position = Util.find_node_by_name(self, "SlideBackPosition")


func get_laser_start_position() -> Vector3:
	var laser_pos : Vector3 = to_global(Vector3.ZERO)
	if laser_pos_marker:
		laser_pos = to_global(laser_pos_marker.position)
	return MathUtil.generate_point_at_LOS_height(laser_pos)


func get_bullet_start_position():
	if not bullet_start_pos_marker:
		return to_global(Vector3.ZERO)
	return to_global(bullet_start_pos_marker.position)


func play_muzzle_flash():
	playing_muzzle_flash = true
	current_muzzle_flash_time = 0
	
	if muzzle_flash:
		muzzle_flash.show()
	
	if muzzle_flash_light:
		muzzle_flash_light.show()
		
	if slide_mesh and slide_back_position and slide_base_position:
		slide_mesh.position = slide_back_position.position
		

func stop_muzzle_flash():
	playing_muzzle_flash = false
	current_muzzle_flash_time = 0
	
	if muzzle_flash:
		muzzle_flash.hide()

	if muzzle_flash_light:
		muzzle_flash_light.hide()

	if slide_mesh and slide_base_position:
		slide_mesh.position = slide_base_position.position


func _physics_process(delta):
	if playing_muzzle_flash:
		current_muzzle_flash_time += delta
		if current_muzzle_flash_time >= muzzle_flash_time:
			stop_muzzle_flash()


func assign_weapon(new_weapon : Weapon):
	weapon = new_weapon


## Returns an array of ejection ports although typically there is only one
func get_ejection_ports() -> Array[EjectionPort]:
	var result:Array[EjectionPort]
	
	for child in get_children():
		if child is EjectionPort:
			result.append(child)
	return result
