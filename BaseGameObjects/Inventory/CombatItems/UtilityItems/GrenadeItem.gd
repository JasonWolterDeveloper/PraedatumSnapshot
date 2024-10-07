extends UtilityItem

class_name GrenadeItem

@export var grenade_projectile_scene : PackedScene = null


func can_throw_grenade():
	return current_quantity > 0


func generate_grenade_projectile() -> GrenadeProjectile:
	if grenade_projectile_scene:
		return grenade_projectile_scene.instantiate()
	return null


func throw_grenade(start_pos : Vector3, end_pos : Vector3):
	var new_grenade: GrenadeProjectile = generate_grenade_projectile()
	Util.force_add_child(Util.get_level(self), new_grenade)
	
	new_grenade.thrower = item_owner
	new_grenade.global_position = start_pos
	
	new_grenade.actually_thrown = true
	new_grenade.throw(start_pos, end_pos)
	current_quantity -= 1



# --------- Equipped Item Use Functions --------- #


func handle_equipped(delta):
	if use_pressed and can_throw_grenade():
			var simulated_projectile : GrenadeProjectile = generate_grenade_projectile()
			var throw_start_position
			AreaOfEffectPredictionMaster.request_projectile_trajectory(simulated_projectile, get_throw_start_position(), GameMaster.get_player().aiming_master.aim_point, 1, item_id)


func on_use_item_released():
	super()
	if can_throw_grenade():
		throw_grenade(get_throw_start_position(), GameMaster.get_player().aiming_master.aim_point)


func get_throw_start_position():
	return GameMaster.get_player().get_non_hitscan_projectile_spawn_location()
