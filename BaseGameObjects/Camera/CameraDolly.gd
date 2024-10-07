class_name CameraDolly extends Node3D

@export var max_z_offset : float = 8.0
@export var min_z_offset : float = -6.0
@export var max_x_offset : float = 9.0
@export var min_x_offset : float = -9.0

@export var x_edge_percentage_to_stop_scrolling : float = 0.8
@export var z_edge_percentage_to_stop_scrolling : float = 0.8

@export var disabled : bool = false


# This is the object that the camera will follow along. It should be set to the
# player by the ready function of the war scene by default. The only reason we
# can't set it here is that we can't access the player during the ready function
# in this object
var objectToFollow = null


# The camera will move according to where the mouse is located on the screen.
# This is mostly used for when making the camera move slightly from its position
# centered around the player by where you aim. Should be turned off for 
# cutscenese probably maybe
var should_have_mouse_aim_offset = true


# The amount of mouse aim off center required to move the offset by 1 pixel is
# represented by this amount. The higher this is, the less responsive the camera
# is to movements by the mouse
@export var mouse_location_to_offset_horizontal_factor = 1.1
@export var mouse_location_to_offset_vertical_factor = mouse_location_to_offset_horizontal_factor


# When accounting for offset of the camera caused by aiming, we don't snap to it
# immediately, we provide some panning to make it look more natural. This is the
# total amount we can change our current offset by per second
var camera_pan_to_desired_offset_speed = 2000


var max_camera_pan_speed = 1000


# The current camera offset represented by a Vector2. We represent it in this 
# way to facilitate gradual rather than instant panning
var current_camera_offset = Vector2(0, 0)

var desired_z_offset = 0
var desired_x_offset = 0


func move_camera_to_position(new_position, delta):
	var direction_to_new_pos = position.direction_to(new_position)
	var distance_to_new_pos = position.distance_to(new_position)
	if distance_to_new_pos < max_camera_pan_speed*delta:
		position = new_position
	else:
		position = position + (max_camera_pan_speed*delta*direction_to_new_pos)


func move_current_offset_towards_desired_offset(delta):
	var desired_offset = generate_desired_offset()
	var total_distance_to_move = current_camera_offset.distance_to(desired_offset)
	var max_distance_can_move_this_frame = camera_pan_to_desired_offset_speed * delta
	var total_distance_can_move = min(total_distance_to_move, max_distance_can_move_this_frame)
	var new_offset = current_camera_offset.move_toward(desired_offset, total_distance_can_move)
	current_camera_offset = new_offset


func generate_desired_offset():
	generate_desired_x_offset()
	generate_desired_z_offset()


func should_update_position():
	if disabled:
		return false
	if get_level().universal_menu_master.are_menus_open():
		return false
	return true


func should_reset_position():
	if disabled:
		return true
	return false


func generate_desired_x_offset():
	var viewport_x_center = Util.get_viewport_center().x * 1.0
	var mouse_pos_x = (get_viewport().get_mouse_position().x) * 1.0
	
	desired_x_offset = 0.0
	
	if mouse_pos_x > viewport_x_center:
		var x_distance_from_center_to_edge = (Util.get_viewport_size().x - viewport_x_center) * 1.0
		var percent_mouse_across_screen = (mouse_pos_x - viewport_x_center)/x_distance_from_center_to_edge
		desired_x_offset = min(percent_mouse_across_screen, x_edge_percentage_to_stop_scrolling) * max_x_offset
	elif mouse_pos_x < viewport_x_center:
		var x_distance_from_center_to_edge = viewport_x_center
		var percent_mouse_across_screen = 1.0 - (mouse_pos_x/x_distance_from_center_to_edge)
		desired_x_offset = min(percent_mouse_across_screen, x_edge_percentage_to_stop_scrolling) * min_x_offset


func generate_desired_z_offset():
	var viewport_y_center = Util.get_viewport_center().y * 1.0
	var mouse_pos_y = (get_viewport().get_mouse_position().y) * 1.0
	
	desired_z_offset = 0.0
	
	if mouse_pos_y > viewport_y_center:
		var y_distance_from_center_to_edge = (Util.get_viewport_size().y - viewport_y_center) * 1.0
		var percent_mouse_across_screen = (mouse_pos_y - viewport_y_center)/y_distance_from_center_to_edge
		desired_z_offset = min(percent_mouse_across_screen, z_edge_percentage_to_stop_scrolling) * max_z_offset
	elif mouse_pos_y < viewport_y_center:
		var y_distance_from_center_to_edge = viewport_y_center
		var percent_mouse_across_screen = 1.0 - (mouse_pos_y/y_distance_from_center_to_edge)
		desired_z_offset = min(percent_mouse_across_screen, z_edge_percentage_to_stop_scrolling) * min_z_offset

"""
func generate_desired_z_offset():
	var viewport_y_center = Util.get_viewport_center().y
	var mouse_pos_y = get_viewport().get_mouse_position().y
	
	# Calculating the total amount of pixels we would slide the camera by if it
	# were only based on the mouse position. This may later be mitigated by the
	# maxmimum limit on the total offset. We need to calculate this because one
	# pixel of mouse movement doesn't necessarily translate to one pixel of 
	# camera offset
	var pixels_to_move_camera_based_on_mouse_pos = (mouse_pos_y - viewport_y_center)/mouse_location_to_offset_vertical_factor
	
	# Limiting the camera offset to the maximum as declared in variables
	var vertical_mouse_offset = max(min_mouse_aim_vertical_offset, min(pixels_to_move_camera_based_on_mouse_pos, max_mouse_aim_vertical_offset))
	return vertical_mouse_offset
"""

func _physics_process(delta):
	# updateCameraPosition(delta)
	if should_update_position():
		generate_desired_offset()
		var desired_pos = Vector3(desired_x_offset, 0, desired_z_offset)
		position = position.lerp(desired_pos, delta)
	if should_reset_position():
		position = Vector3.ZERO


func get_level() -> Level:
	return Util.get_level(self)


func get_player():
	return get_level().get_player()


""" To track non player objects
		
func followObject(myObject):
	setObjectToFollow(myObject)
		
func follow_player():
	follow_object(getPlayer())
	
func stopFollowingAllObjects():
	follow_object(null)
"""
	
""" TODO - These Functions used for Cinematics. Could be used for other Situations like shops in the future]

# In 'gameplay mode' the camera is locked onto the player character, and aiming 
# can move the camera away from the player character to allow the player to see 
# more of the environment
func switchCameraToGameplayMode():
	follow_payer()
	setshould_have_mouse_aim_offset(true)
	
# In 'cinematic mode' The movements of the camera should be controlled by the
# cinematic, so we don't follow anyone, and the position of the camera shouldn't
# be impacted by mouse aim
func switchCameraToCinematicMode():
	stopFollowingAllObjects()
	setshould_have_mouse_aim_offset(false)
	
# In 'cinematic follow object mode' the camera does follow an object, but that
# object needs to be passed into the function, and the camera still does not
# respond to where the mouse is positioned
func switchCameraToCinematicFollowObjectMode(objectToFollow):
	followObject(objectToFollow)
	setshould_have_mouse_aim_offset(false)
"""

"""

func getModel():
	return Util.getModel(self)

##### Getters and Setters #####


func getObjectToFollow():
	return objectToFollow

func setObjectToFollow(val):
	objectToFollow = val


func getshould_have_mouse_aim_offset():
	return should_have_mouse_aim_offset

func setshould_have_mouse_aim_offset(val):
	should_have_mouse_aim_offset = val

func getmax_mouse_aim_horizontal_offset():
	return max_mouse_aim_horizontal_offset

func setmax_mouse_aim_horizontal_offset(val):
	max_mouse_aim_horizontal_offset = val

func getmin_mouse_aim_horizontal_offset():
	return min_mouse_aim_horizontal_offset

func setmin_mouse_aim_horizontal_offset(val):
	min_mouse_aim_horizontal_offset = val

func getmax_mouse_aim_vertical_offset():
	return max_mouse_aim_vertical_offset

func setmax_mouse_aim_vertical_offset(val):
	max_mouse_aim_vertical_offset = val

func getmin_mouse_aim_vertical_offset():
	return min_mouse_aim_vertical_offset

func setmin_mouse_aim_vertical_offset(val):
	min_mouse_aim_vertical_offset = val

func getmouse_location_to_offset_horizontal_factor():
	return mouse_location_to_offset_horizontal_factor

func setmouse_location_to_offset_horizontal_factor(val):
	mouse_location_to_offset_horizontal_factor = val

func getmouse_location_to_offset_vertical_factor():
	return mouse_location_to_offset_vertical_factor

func setmouse_location_to_offset_vertical_factor(val):
	mouse_location_to_offset_vertical_factor = val

func getcamera_pan_to_desired_offset_speed():
	return camera_pan_to_desired_offset_speed

func setcamera_pan_to_desired_offset_speed(val):
	camera_pan_to_desired_offset_speed = val

func getCurrentCameraOffset():
	return currentCameraOffset

func setCurrentCameraOffset(val):
	currentCameraOffset = val

"""
