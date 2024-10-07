class_name FragGrenadeItem extends GrenadeItem

const CURRENT_GRENADE_SIZE_KEY = "GrenadeSize"

@export var grenade_medium_projectile_scene : PackedScene = null
@export var grenade_large_projectile_scene : PackedScene = null

@export var small_inventory_image : Texture = null
@export var medium_inventory_image : Texture = null
@export var large_inventory_image : Texture = null

enum grenade_sizes{SMALL, MEDIUM, LARGE}

var current_grenade_size : grenade_sizes = grenade_sizes.SMALL


func generate_grenade_projectile() -> GrenadeProjectile:
	if current_grenade_size == grenade_sizes.SMALL:	
		if grenade_projectile_scene:
			return grenade_projectile_scene.instantiate()
	if current_grenade_size == grenade_sizes.MEDIUM:
		if grenade_medium_projectile_scene:
			return grenade_medium_projectile_scene.instantiate()
	if current_grenade_size == grenade_sizes.LARGE:
		if grenade_large_projectile_scene:
			return grenade_large_projectile_scene.instantiate()
	return null


func instantiate_self():
	var self_scene = load(scene_file_path)
	return self_scene.instantiate()


func find_grenade_for_stacking():
	if get_wielder():
		var grenade_list = get_wielder().inventory.find_all_items_of_type_in_storage(FragGrenadeItem)
		# We only stack using single stack grenades
		for my_grenade : FragGrenadeItem in grenade_list:
			if my_grenade.current_grenade_size == grenade_sizes.SMALL:
				return my_grenade
	return null


func can_stack_grenade():
	if current_grenade_size == grenade_sizes.LARGE:
		return false
	else:
		var grenade_for_stacking = find_grenade_for_stacking()
		return grenade_for_stacking != null


func stack_grenade():
	var grenade_for_stacking = find_grenade_for_stacking()
	if grenade_for_stacking:
		if current_grenade_size == grenade_sizes.MEDIUM:
			grenade_for_stacking.queue_free()
			change_grenade_size(grenade_sizes.LARGE)
		elif current_grenade_size == grenade_sizes.SMALL:
			grenade_for_stacking.queue_free()
			change_grenade_size(grenade_sizes.MEDIUM)


func unstack_grenade():
	if current_grenade_size > grenade_sizes.SMALL:
		var new_grenade = instantiate_self()
		if get_wielder().inventory.storage_can_fit_anywhere(new_grenade):
			get_wielder().inventory.storage_insert_anywhere(new_grenade)
			change_grenade_size(current_grenade_size - 1)


func change_grenade_size(new_size : grenade_sizes):
	if new_size == grenade_sizes.MEDIUM:
		current_grenade_size = new_size
		grid_square_height = 2
		inventory_image = medium_inventory_image
	elif new_size == grenade_sizes.LARGE:
		current_grenade_size = new_size
		grid_square_height = 3
		inventory_image = large_inventory_image
	elif new_size == grenade_sizes.SMALL:
		current_grenade_size = new_size
		grid_square_height = 1
		inventory_image = small_inventory_image


func alt_use_utility():
	if can_stack_grenade():
		stack_grenade()
	else:
		if current_grenade_size == grenade_sizes.LARGE: # If we are currently the largest possible grenade, we want to try and unstack twice
			unstack_grenade()
		unstack_grenade()


func load_from_dictionary(load_dictionary):
	super(load_dictionary)
	if load_dictionary.has(CURRENT_GRENADE_SIZE_KEY):
		change_grenade_size(load_dictionary[CURRENT_GRENADE_SIZE_KEY])


func generate_save_dictionary():
	var save_dictionary = super()
	
	save_dictionary[CURRENT_GRENADE_SIZE_KEY] = current_grenade_size
	
	return save_dictionary
