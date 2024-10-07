class_name Level extends Node3D

const HUB_LEVEL_SCENE_PATH = "res://Content/Default/Code/Levels/HubLevel.tscn"
const COLLISION_LAYER_20_COLLISION_MASK = 524288 # Wtf

@export var stash_storage : StashStorage
@export var is_hub_level = false

var ray_origin = Vector3()
var ray_target = Vector3()

var game_world_mouse_position = Vector3(0, 0, 0)


@onready var player : Player = $Player
@onready var crosshair = $Crosshair3D
@onready var camera = $Player/CameraDolly/CameraGimbal/InnerGimbal/Camera3D

@onready var universal_menu_master : UniversalMenuMaster = $UILayer/UniversalMenuMaster
@onready var room_master : RoomMaster = $RoomMaster

@onready var sound_master:SoundMaster = $SoundMaster


func _ready():
	# NOTE Must be cleared before saving and loading
	HomeBaseFacilityMaster.clear_home_base_facility_list()
	
	# We will only ever have one level at a time so we assign ourselves to the 
	# game master here
	GameMaster.assign_level(self)
	
	SaveMaster.assign_level(self)
	SaveMaster.load_player_persistent_data_tome()
	if player:
		SaveMaster.load_player_inventory()
		player.controller.universal_menu_master = universal_menu_master
		player.controller.level = self
	if stash_storage:
		SaveMaster.load_player_stash()
		
	if universal_menu_master:
		universal_menu_master.assign_level(self)
		universal_menu_master.assign_player(player)
		
	room_master.handle_room_spawns()
	# DEPRECATED - Level Exits are now hand placed and not randomized
	# room_master.handle_level_exit_setup()
	
	if room_master.exit_room:
		OnScreenMessageMaster.display_message("Exit Spawned in: " + str(room_master.exit_room.display_name), 10)
	
	assign_target_characters()
	
	# Running the init function for triggers
	## TODO: Probably just run init for every variable that has it
	TriggerMaster.clear_triggers()
	add_all_triggers_to_trigger_master(self)
	TriggerMaster.init_triggers()
	
	crosshair.set_player(player)
	crosshair.set_camera(camera)
	crosshair.univeral_menu_master = universal_menu_master

	$UILayer/PlayerHUD.assign_player(player)
	assign_camera(self, camera)
	
	if sound_master:
		DebugMaster.log_debug("Playing Ambient Music")
		sound_master.play("AmbientMusic")
		
	QuestSystemMaster.track_any_quest_if_tracking_no_quests()
	WarriorMaster.load_current_warrior_RPG_mechanics_from_persistent_data_tome()
	
	init_tree(self)

func add_all_triggers_to_trigger_master(node):
	for child in node.get_children():
		if child is Trigger:
			child.add_to_trigger_master()
		add_all_triggers_to_trigger_master(child)


## Recursively sets each AIMemory's target_character to the player
func assign_target_characters(node = self):
	for child in node.get_children():
		if child is AIMemory:
			child.target_character = player
		assign_target_characters(child)


func assign_camera(node: Node, new_camera: Camera3D) -> void:
	# Loop through each child of the node
	for child in node.get_children():
		# Check if the child has the method "assign_camera"
		if child.has_method("assign_camera"):
			# Call the "assign_camera" method with the camera parameter
			child.assign_camera(new_camera)
		
		# Recursively call this function on the child
		assign_camera(child, new_camera)


func change_level(new_level):
	SaveMaster.save_player_inventory()
	SaveMaster.save_player_stash()
	SaveMaster.save_player_persistent_data_tome()
	if new_level is PackedScene:
		get_tree().change_scene_to_packed(new_level)
	else:
		get_tree().change_scene_to_file(new_level)
	
	
func return_to_hub_level():
	change_level(HUB_LEVEL_SCENE_PATH)


func handle_successful_extraction():
	GlobalConfigMaster.set_previous_raid_successful()
	return_to_hub_level()


func handle_player_death():
	GlobalConfigMaster.set_previous_raid_failure()
	return_to_hub_level()


func _process(delta):
	pass
	"""
	if Input.is_action_just_pressed("debug_5"):
		SaveMaster.save_player_inventory()
		SaveMaster.save_player_stash()dd
		SaveMaster.save_player_rpg_mechanics()
	if Input.is_action_just_pressed("debug_6"):
		SaveMaster.load_player_inventory()
		SaveMaster.load_player_stash()
		SaveMaster.load_player_rpg_mechanics()
	"""


func _physics_process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	
	ray_origin = camera.project_ray_origin(mouse_position)
	
	ray_target = ray_origin + camera.project_ray_normal(mouse_position) * 2000
	
	var params = PhysicsRayQueryParameters3D.new()
	params.from = ray_origin
	params.to = ray_target
	params.collision_mask = COLLISION_LAYER_20_COLLISION_MASK
	
	var space_state = get_world_3d().direct_space_state
	var intersection = space_state.intersect_ray(params)

	if not intersection.is_empty():
		var pos = intersection.position
		var look_at_me = Vector3(pos.x, player.position.y, pos.z)
		game_world_mouse_position = look_at_me


func handle_quit():
	#  We don't want to save the player inventory if they are deployed and quit the game
	# only if they are safely at home
	if is_hub_level:
		SaveMaster.save_player_inventory()
		SaveMaster.save_player_stash()
		SaveMaster.save_player_persistent_data_tome()


func get_inventory_ui_master():
	return universal_menu_master.get_inventory_ui_master()


func get_player():
	return player


func get_player_inventory():
	return get_player().inventory


## Recursively calls init on all objects in the scene tree that have 12it. init() is analagous to
## _ready() in that its purpose is to set up a node, but is called after ready top-down (root to
## leaves) in the scene tree. 
func init_tree(some_node:Node) -> void:
	for child in some_node.get_children():
		if child.has_method("init"):
			child.init()
		init_tree(child)


"""

extends Node3D

var player:
	get:a return get_player()
var player_inventory:
	get: return get_player_inventory()
var inventory_ui_master:
	get: return get_inventory_ui_master()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST || what == NOTIFICATION_WM_GO_BACK_REQUEST:
		handle_quit()

func get_player():
	return get_node("Player")
	
func get_player_inventory():
	return get_player().inventory
	
func get_inventory_ui_master():
	return get_node("UILayer").get_node("InventoryUIMaster")
"""
