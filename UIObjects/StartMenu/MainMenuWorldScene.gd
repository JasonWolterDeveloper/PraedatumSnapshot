extends Node3D

var start_game_level_scene_path = "res://Content/Default/Code/Levels/HubLevel.tscn"

@onready var animation_player := $AnimationPlayer

@onready var light_1 := $Menu3DStuff/PraedatumText/LaserLight1
@onready var light_2 := $Menu3DStuff/PraedatumText/LaserLight2
@onready var light_3 := $Menu3DStuff/PraedatumText/LaserLight3

@onready var beam_mesh := $Menu3DStuff/PlayerModel2/PistolPos/BackupPistolModel/LaserPos/BeamMesh2
@onready var point_mesh := $Menu3DStuff/PlayerModel2/PistolPos/BackupPistolModel/LaserPos/PointMesh2

@onready var model_hider = $Menu3DStuff/ModelHider
@onready var menu = $CanvasLayer/Control

@onready var sub_titles = $CanvasLayer/SubTitles

var create_character_menu
var load_character_menu

# ----- Menu Control References ----- #
var start_new_game_control : StartNewGameControl
var load_game_control : LoadGameMenuControl

var opening_title_running = true
var opening_title_skipped = false


func _ready():
	find_and_assign_create_character_menu()
	find_and_assign_load_character_menu()
	handle_continue_button_visibility()
	
	find_and_assign_start_new_game_menu()
	find_and_assign_load_game_menu_control()


func _process(delta):
	if Input.is_action_just_pressed("ui_click"):
		if opening_title_running and can_skip_opening_tile():
			skip_opening_titles()


func skip_opening_titles():
	sub_titles.hide()
	animation_player.stop()
	opening_title_skipped = true
	play_intro_animation()


func can_skip_opening_tile():
	return GlobalConfigMaster.get_value_for_key("seen_opening_titles") == true


func handle_continue_button_visibility():
	var continue_button = Util.find_node_by_name(self, "ContinueButton")
	if GlobalConfigMaster. get_selected_character_name() != "":
		continue_button.show()
	else:
		continue_button.hide()


func find_and_assign_load_character_menu():
	load_character_menu = Util.find_node_by_name(self, "LoadCharacterMenu")
	load_character_menu.assign_main_menu(self)


func find_and_assign_create_character_menu():
	create_character_menu = Util.find_node_by_name(self, "CreateCharacterMenu")
	create_character_menu.assign_main_menu(self)


func find_and_assign_start_new_game_menu():
	start_new_game_control = Util.find_node_by_name(self, "StartNewGameControl")
	start_new_game_control.assign_main_menu(self)


func find_and_assign_load_game_menu_control():
	load_game_control = Util.find_node_by_name(self, "LoadGameMenuControl")
	load_game_control.assign_main_menu(self)
	
	
func start_game_for_character(character_name : String):
	GlobalConfigMaster.set_selected_character_name(character_name)
	get_tree().change_scene_to_file(start_game_level_scene_path)


func play_opening_scroll():
	if not opening_title_skipped:
		animation_player.speed_scale = 0.85
		sub_titles.show()
		animation_player.play("opening_scroll_1")
		await animation_player.animation_finished
		animation_player.play("opening_scroll_2")
		await animation_player.animation_finished
		animation_player.play("opening_scroll_3")
		await animation_player.animation_finished
		animation_player.play("opening_scroll_4")
		await animation_player.animation_finished
		GlobalConfigMaster.set_value_for_key("seen_opening_titles", true)
		if not opening_title_skipped:
			play_intro_animation()


func play_intro_animation():
	opening_title_running = false
	animation_player.speed_scale = 0.75
	animation_player.play("text_fade_in")
	await animation_player.animation_finished
	menu.show()
	animation_player.play("models_fade_in")
	await animation_player.animation_finished
	model_hider.hide()
	light_1.show()
	light_2.show()
	light_3.show()
	beam_mesh.show()
	point_mesh.show()
	animation_player.play("laser_light_fade_in")
	

func open_load_character_menu():
	load_character_menu.display_load_menu()


func _on_start_game_pressed():
	if GlobalConfigMaster.get_selected_character_name() != "":
		start_game_for_character(GlobalConfigMaster.get_selected_character_name())


func _on_new_character_pressed():
	start_new_game_control.display_menu()
	# create_character_menu.show()


func _on_load_button_pressed():
	load_game_control.display_menu()


func _on_timer_timeout():
	play_opening_scroll()


func _on_exit_button_pressed():
	get_tree().quit()
