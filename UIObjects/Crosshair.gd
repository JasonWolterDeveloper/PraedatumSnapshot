extends Node3D

const DEBUG_VISUALIZATION = false
const EXTRA_TOLERANCE = 0.25

var player = null
var camera: Camera3D = null
var univeral_menu_master : UniversalMenuMaster = null
var weapon: Weapon :
	get: 
		if player.get_equipped_item() is Gun:
			return player.get_equipped_item()
		return null

@onready var crosshair_plane = $CrosshairPlane
@onready var sphere_1 = $Sphere1
@onready var sphere_2 = $Sphere2
@onready var sphere_3 = $Sphere3
@onready var sphere_4 = $Sphere4
@onready var sphere_5 = $Sphere5

@onready var crosshair_2d = $Crosshair2D
@onready var reloading_crosshair = $ReloadingCrosshair
@onready var ol_reliable_charge_bar = $OlReliableChargeBar


func _ready():
	if DEBUG_VISUALIZATION:
		sphere_1.show()
		sphere_2.show()
		sphere_3.show()
		sphere_4.show()
		sphere_5.show()
	pass


func set_player(new_player : Player):
	player = new_player
	reloading_crosshair.set_player(new_player)


func set_camera(new_camera):
	camera = new_camera


func _process(delta):
	var crosshair_radius

	
	if player and camera:	
		$Crosshair2DBase.global_position = $Crosshair2DBase.get_global_mouse_position()
		if should_hide_basic_crosshair():
			$Crosshair2DBase.hide()
		else:
			$Crosshair2DBase.show()
		if weapon is Gun:
			crosshair_radius = generate_screen_radius()
			crosshair_2d.crosshair_radius = crosshair_radius
			if should_hide_2D_crosshair():
				crosshair_2d.hide()
			else:
				crosshair_2d.show()
				
			if should_hide_ol_reliable_charge_bar():
				ol_reliable_charge_bar.hide()
			else:
				ol_reliable_charge_bar.the_gun = weapon
				ol_reliable_charge_bar.radius = crosshair_radius
				ol_reliable_charge_bar.show()
		else:
			crosshair_2d.hide()
			ol_reliable_charge_bar.hide()
		
		if DEBUG_VISUALIZATION:
			position_spheres()


func generate_extra_tolerance_value():
	return EXTRA_TOLERANCE


 #generate_screen_radius() is a function that returns the radius of a 2D circle, which, if centered
 #on the player's aimpoint, should have all bullets fired by the player pass through it.
 #It accomplishes this by calculating the center point and radius of a 3D sphere which all of the
 #player's rounds will definitely pass through. Then, it finds a point on the edge of the sphere
 #and projects both the center point and the point on the edge of the sphere into the screen's
 #2D coordinate system. Finally, it calculates the distance between these two points in 2D space
 #to generate the radius
func generate_screen_radius():
	# Put the 3D Center Point of the crosshair on the floor at the player's aim point
	var center_point = 	Vector3(player.aiming_master.aim_point.x, 0, player.aiming_master.aim_point.z)
	
	# Generating the radius of a 3D sphere at the aim point that all fired bullets will pass through
	# Note that the extra tolerance is necessasry both, to make the crosshair feel better to the 
	# player, but also because the actual rounds are raised a certain level above the ground, which
	# means that the center point does not perfectly align with the center of the spread of rounds
	# meaning the extra tolerance is necessary
	var transform_scale_value = player.aiming_master.calculate_spread_circle_radius_for_spread(weapon.calculate_spread()) + generate_extra_tolerance_value()
	
	# Generating a point on the edge of the sphere that IMPORTANTLY maximizes the visual distance
	# between that point and the center point from the perspective of the camera. We do this by
	# generating a vector straight upward relative to the camera, transforming that vector into
	# the global coordinate system, moving that vector to the global origin, scaling the vector
	# by the size of the radius calulated above, and then moving the vector's origin to the center
	# point of the 3D sphere. This gets us a point on the top of the sphere, relative to the camera
	var upper_point_direction_vector = camera.to_global(Vector3.UP) - camera.global_position
	var upper_point_movement_vector = upper_point_direction_vector*transform_scale_value
	var upper_point = center_point + upper_point_movement_vector
	
	# Getting the center point and the point on the edge of the sphere in 2D screen space
	var center_point_2D = camera.unproject_position(center_point)
	var upper_point_2D = camera.unproject_position(upper_point)
	
	# Returning the distance between these two points as the radius of our crosshair
	return center_point_2D.distance_to(upper_point_2D)


func position_spheres():
	var sphere1_center_point = Vector3(player.aiming_master.aim_point.x, 0, player.aiming_master.aim_point.z)
	sphere_1.global_position = 	sphere1_center_point
	
	var transform_scale_value = player.aiming_master.get_spread_circle_radius() + EXTRA_TOLERANCE
	
	var sphere_2_direction_vector = camera.to_global(Vector3.UP) - camera.global_position
	var sphere_2_movement_vector = sphere_2_direction_vector*transform_scale_value
	sphere_2.global_position = sphere1_center_point + sphere_2_movement_vector
	
	var sphere_3_direction_vector = camera.to_global(Vector3.LEFT) - camera.global_position
	var sphere_3_movement_vector = sphere_3_direction_vector*transform_scale_value
	sphere_3.global_position = sphere1_center_point + sphere_3_movement_vector
	
	var sphere_4_direction_vector = camera.to_global(Vector3.DOWN) - camera.global_position
	var sphere_4_movement_vector = sphere_4_direction_vector*transform_scale_value
	sphere_4.global_position = sphere1_center_point + sphere_4_movement_vector
	
	var sphere_5_direction_vector = camera.to_global(Vector3.RIGHT) - camera.global_position
	var sphere_5_movement_vector = sphere_5_direction_vector*transform_scale_value
	sphere_5.global_position = sphere1_center_point + sphere_5_movement_vector
	
#func calculate_screen_coordinates	


func should_hide_2D_crosshair():
	if not weapon or player.is_reloading() or weapon.use_custom_crosshair:
		return true
	if univeral_menu_master:
		return univeral_menu_master.are_menus_open()
	return false
	

func should_hide_basic_crosshair():
	if univeral_menu_master:
		return univeral_menu_master.are_menus_open()
	return false
	

func should_hide_ol_reliable_charge_bar() -> bool:
	var player_gun:Gun = weapon
	if player_gun and player_gun is OlReliable:
		if player_gun.use_custom_crosshair or player_gun.curr_charge_time > 0.0:
			return false
	return true


	"""
	if Util.getModel(self).getCinematicManager().getCinematicMode().inCinematicMode():
		return true
	if nothingToTrack():
		return true
	return getHideCrosshairOverride()
	"""
