class_name RaidMenu extends Control

@export var test_level_scene_path = "res://Content/Demo/Code/Levels/AITestLevel.tscn"
@export var other_level_scene_path = "res://Content/Demo/Code/Levels/RoomSystemTestLevel.tscn"
@export var level_1_scene_path = "res://Content/Demo/Code/Levels/Level1/Level1.tscn"
@export var foreman_office_scene_path = "res://Content/Demo/Code/Levels/Level1/Rooms/ForemansOffice/ForemanOfficeLevel.tscn"
@export var level_1_packed_scene : PackedScene

var currently_selected_level = level_1_scene_path

func start_raid():
	Util.get_level(self).change_level(currently_selected_level)


func _on_start_raid_button_pressed():
	start_raid()


func _on_foyer_button_toggled(toggled_on):
	currently_selected_level = level_1_packed_scene
	$HBoxContainer/FoyerButton.set_pressed_no_signal(true)
	$HBoxContainer/TestLevelButton.set_pressed_no_signal(false)
	$HBoxContainer/ForemanOfficeButton.set_pressed_no_signal(false)


func _on_warehouse_button_toggled(toggled_on):
	currently_selected_level = other_level_scene_path
	$HBoxContainer/FoyerButton.set_pressed_no_signal(false)


func _on_test_level_button_toggled(toggled_on):
	currently_selected_level = test_level_scene_path
	$HBoxContainer/FoyerButton.set_pressed_no_signal(false)
	$HBoxContainer/TestLevelButton.set_pressed_no_signal(true)
	$HBoxContainer/ForemanOfficeButton.set_pressed_no_signal(false)


func _on_foreman_office_toggled(toggled_on: bool) -> void:
	currently_selected_level = foreman_office_scene_path
	$HBoxContainer/FoyerButton.set_pressed_no_signal(false)
	$HBoxContainer/TestLevelButton.set_pressed_no_signal(false)
	$HBoxContainer/ForemanOfficeButton.set_pressed_no_signal(true)
	pass # Replace with function body.
