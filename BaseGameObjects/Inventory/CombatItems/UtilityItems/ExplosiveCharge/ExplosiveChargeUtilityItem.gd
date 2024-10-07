class_name ExplosiveChargeUtilityItem extends UtilityItem

@export var charge_inventory_image : Texture
@export var detonator_inventory_image : Texture
@export var placed_explosive_charge_scene : PackedScene

@export var allow_place_on_walls : bool = true
@export var allow_place_on_ground : bool = true
@export var place_on_wall_range : float = 2.0

@export var ground_placement_height : float = 0.1
@export var wall_placement_height : float = 1.2

# Move the placed charge towards the player by this amount. We do this so that
# thew Explosive charge isn't partially embedded in the wall
@export var shift_towards_player_amount : float = 0.05

var charge_to_detonate : PlacedExplosiveCharge


func _ready():
	assert(placed_explosive_charge_scene != null)


func generate_placed_explosive_charge():
	return placed_explosive_charge_scene.instantiate()


func is_explosive_charge_placed():
	return charge_to_detonate != null


func place_explosive_charge_on_door(door, side):
	current_quantity -= 1
	
	charge_to_detonate = generate_placed_explosive_charge()
	
	charge_to_detonate.place_on_door(door, side)
	
	inventory_image = detonator_inventory_image


func can_place_charge():
	return not is_explosive_charge_placed()
	

func place_explosive_charge():
	var placement_info = find_placement_position_and_facing()
	var this_is_for_debug = get_wielder().global_position
	var placement_position = placement_info[0]
	var placement_facing = placement_info[1]
	charge_to_detonate = generate_placed_explosive_charge()
	charge_to_detonate.place_on_ground(placement_position, Util.get_level(self))
	charge_to_detonate.face_toward(placement_facing)
	inventory_image = detonator_inventory_image


func detonate_placed_charge():
	if charge_to_detonate:
		charge_to_detonate.detonate()
		charge_to_detonate = null


func use_utility():
	if is_explosive_charge_placed():
		detonate_placed_charge()
		current_quantity -= 1


func find_wall_placement_position_and_facing():
	var raycast_start_pos = Vector3(get_wielder().global_position.x, wall_placement_height, get_wielder().global_position.z)
	var heading_vector = get_wielder().aiming_master.look_direction_vector().normalized()
	var raycast_end_pos = raycast_start_pos + (heading_vector * place_on_wall_range)
	var collision_info = raycast(raycast_start_pos, raycast_end_pos)

	
	if collision_info:
		# Doing the work to move towards the player
		var direction_to_player = collision_info.position.direction_to(get_wielder().global_position)
		var direction_to_player_no_y = Vector3(direction_to_player.x, 0, direction_to_player.z).normalized()
		var move_amount = direction_to_player_no_y * shift_towards_player_amount
		
		var final_position = collision_info.position + move_amount
		
		# Adding the normal to the final  position so we know what direction we should look in
		var facing_position = final_position + collision_info.normal
		return [final_position, facing_position]
	return null
	
	
func find_ground_placement_position_and_facing():
	return [Vector3(get_wielder().global_position.x, ground_placement_height, get_wielder().global_position.z), get_wielder().aiming_master.aim_point]


func find_placement_position_and_facing():
	var placement_info = null
	
	if allow_place_on_walls:
		placement_info = find_wall_placement_position_and_facing()
	 
	if not placement_info and allow_place_on_ground:
		placement_info = find_ground_placement_position_and_facing()
		 
	return placement_info  
	

func find_placement_position():
	return find_placement_position_and_facing()[0]
		
		
# By default, collides with only PhysicsBodies on layers #1. See the documentation for 
# PhysicsDirectSpaceState3D.intersect_ray() for the return value content.
func raycast(ray_start:Vector3, ray_end:Vector3, mask:int=0x1) -> Dictionary:
	var params := PhysicsRayQueryParameters3D.new()
	params.collision_mask = mask
	params.from = ray_start
	params.to = ray_end
	
	DebugMaster.log_debug("RayCast start Position: " + str(ray_start))
	DebugMaster.log_debug("RayCast end Position" + str(ray_end))
	
	var space_state := get_world_3d().direct_space_state
	return space_state.intersect_ray(params)
	
