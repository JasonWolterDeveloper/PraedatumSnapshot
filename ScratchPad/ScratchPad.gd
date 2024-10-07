extends Node3D

@export var scratch_object_scene : PackedScene
var is_ready = false;
@onready var my_scratch_object = $ScratchObject
@onready var test_area = $Area3D
@onready var test_area_2 = $Area3D2

func _ready():
	$rotate/AnimationPlayer.play("rotate")
	for my_child in get_children():
		this_accepts_any_object(my_scratch_object)
	test_area.force_update_transform()
	for my_object in test_area.get_overlapping_areas():
		print("hey")
		DebugMaster.log_debug(my_object.name)
	test_area_2.force_update_transform()
	for my_object in test_area_2.get_overlapping_areas():
		print('Hey 2')
		DebugMaster.log_debug(my_object.name)

func _physics_process(delta):
	for my_object in test_area.get_overlapping_areas():
		DebugMaster.log_debug("This is the ultimate test")
	
func this_accepts_any_object(my_object):
	my_object.foo()
	
