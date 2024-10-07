class_name MoraleBuffMaster extends Node

# ----- Save Constants ----- #
const ACTIVE_MORALE_BUFFS_SAVE_KEY = "active_morale_buffs"

@export var active_morale_buffs : Array[MoraleBuff] = []

# ----- Model Vars ----- #
var rpg_mechanics_master : RPGMechanicsMaster
var player : Player

# ----- Inventory Change Information ----- #
var max_inventory_width_addition : int = 0



# ---------- Ready and Assignment Functions --------- #


# TODO something fucky is going on with assignment functions here
func assign_player(new_player : Player):
	player = new_player
	
	# I think it might be that the player's rpg mechanics master isn't assigned
	# when we run this... maybe
	# rpg_mechanics_master = player.rpg_mechanics_master 


func assign_rpg_mechanics_master(new_rpg_mechanics_master : RPGMechanicsMaster):
	rpg_mechanics_master = new_rpg_mechanics_master



# ---------- Adding and Removing Buffs ---------- #


func check_can_add_morale_buff(morale_buff: MoraleBuff):
	var number_of_active_buffs = get_number_of_active_buffs()
	var total_buff_slots = get_total_morale_buff_slots()
	if number_of_active_buffs < total_buff_slots:
		return true
	return false


func check_for_matching_morale_buff_for_refresh(morale_buff : MoraleBuff):
	for my_morale_buff : MoraleBuff in active_morale_buffs:
		if my_morale_buff.id == morale_buff.id:
			return my_morale_buff
	return null


func check_can_refresh_or_add_morale_buff(morale_buff: MoraleBuff):
	return check_can_add_morale_buff(morale_buff) or check_for_matching_morale_buff_for_refresh(morale_buff)


func attempt_add_or_refresh_morale_buff(morale_buff: MoraleBuff):
	var matching_buff : MoraleBuff = check_for_matching_morale_buff_for_refresh(morale_buff)
	if matching_buff:
		refresh_morale_buff(matching_buff)
	elif check_can_add_morale_buff(morale_buff):
		add_morale_buff(morale_buff)


func refresh_morale_buff(morale_buff : MoraleBuff):
	RPGEventMaster.invoke_start_morale_buff_event(morale_buff)


func add_morale_buff(morale_buff : MoraleBuff):
	active_morale_buffs.append(morale_buff)
	morale_buff.assign_morale_buff_master(self)
	
	if rpg_mechanics_master:
		rpg_mechanics_master.notify_morale_buff_added(morale_buff)
	
	update_maximum_inventory_width_addition()
	RPGEventMaster.invoke_start_morale_buff_event(morale_buff)


func remove_morale_buff(morale_buff : MoraleBuff):
	Util.delete_object_from_array(active_morale_buffs, morale_buff)
	if rpg_mechanics_master:
		rpg_mechanics_master.notify_morale_buff_removed(morale_buff)
	
	update_maximum_inventory_width_addition()


func clear_morale_buffs():
	var buffs_to_remove = []
	for my_buff in active_morale_buffs:
		buffs_to_remove.append(my_buff)
	for my_buff in buffs_to_remove:
		remove_morale_buff(my_buff)



# --------- Inventory Width Functions --------- #


func update_maximum_inventory_width_addition():
	var previous_max_inventory_width_addition : int = max_inventory_width_addition
	max_inventory_width_addition = 0
	
	for my_morale_buff : MoraleBuff in active_morale_buffs:
		if my_morale_buff.inventory_width_increase > max_inventory_width_addition:
			max_inventory_width_addition = my_morale_buff.inventory_width_increase
	
	if previous_max_inventory_width_addition != max_inventory_width_addition:
		InventoryMaster.player_inventory.update_inventory_size()



# ---------- Processing Morale Buffs ----------- #


func process_all_morale_buffs(delta : float) -> void:
	var level : Level = GameMaster.get_level()
	
	# We only want to degrade our morale buff timers if we are not in the Hub
	if level and not level.is_hub_level:
		for morale_buff : MoraleBuff in active_morale_buffs:
			morale_buff.update(delta)


func _process(delta):
	process_all_morale_buffs(delta)



# ---------- Saving and Loading Functions ---------- #


func generate_active_morale_buffs_save_array() -> Array[Dictionary]:
	var morale_buff_save_array : Array[Dictionary] = []
	for morale_buff : MoraleBuff in active_morale_buffs:
		morale_buff_save_array.append(morale_buff.generate_save_dictionary())
	return morale_buff_save_array


func load_active_morale_buffs_from_array(load_array : Array) -> void:
	# First we clear the Buffs. We do this because sometimes we get loaded from file twice in a row
	# Or when we already have existing data
	clear_morale_buffs()
	for morale_buff_save_entry in load_array:
		var morale_buff : MoraleBuff = SaveLoadUtil.load_object_from_object_entry(morale_buff_save_entry)
		add_morale_buff(morale_buff)
		
		# TODO - This is cringe, but, add morale buff resets our timer, so we have to fix that by
		# loading from dictionary a second time
		morale_buff.load_from_dictionary(morale_buff_save_entry)


func generate_save_dictionary() -> Dictionary:
	var save_dictionary : Dictionary = {}
	
	save_dictionary[ACTIVE_MORALE_BUFFS_SAVE_KEY] = generate_active_morale_buffs_save_array()
	
	return save_dictionary


func load_from_dictionary(load_dictionary : Dictionary) -> void:
	if load_dictionary.has(ACTIVE_MORALE_BUFFS_SAVE_KEY):
		load_active_morale_buffs_from_array(load_dictionary[ACTIVE_MORALE_BUFFS_SAVE_KEY])


# ---------- Getters and Setters --------- #


func get_number_of_active_buffs() -> int:
	return len(active_morale_buffs)


func get_total_morale_buff_slots() -> int:
	if rpg_mechanics_master and rpg_mechanics_master.number_of_morale_buff_slots:
		return int(rpg_mechanics_master.number_of_morale_buff_slots.value)
	return 0


func get_buff_for_slot_index(slot_index : int) -> MoraleBuff:
	if slot_index >= len(active_morale_buffs):
		return null
	return active_morale_buffs[slot_index]


func get_max_inventory_width_addition():
	return max_inventory_width_addition
