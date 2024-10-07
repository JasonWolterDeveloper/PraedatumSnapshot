class_name PhysicalEnemySpawner extends Node3D

@onready var sign_animation_player := $SignAnimation
@onready var spawn_animation_player := $SpawnAnimation

# ----- Generic Spawn Information ----- #
@export var spawn_scene : PackedScene
@export var move_time : float = 0.5
@export var starting_state : StringName = "WanderState"

# ----- Spawn Marker Information ----- #
@export var pos_marker : Marker3D
@export var move_marker : Marker3D
@export var look_marker : Marker3D

# ----- Tracking Vars ----- #
var most_recently_spawned_enemy : Enemy



func _ready() -> void:
	sign_animation_player.play("SignAnimation")


func spawn():
	spawn_animation_player.play("spawn")


func spawn_enemy():
	most_recently_spawned_enemy = spawn_scene.instantiate()
	
	# Calling tihs as move marker initially so our initial position information
	# gets inited properly
	most_recently_spawned_enemy.global_position = move_marker.global_position
	most_recently_spawned_enemy.initial_state_name = starting_state
	most_recently_spawned_enemy.behaviour_debug_mode = true
	GameMaster.get_level().add_child(most_recently_spawned_enemy)
	
	# Must come after Adding to level such that ready has already fired
	most_recently_spawned_enemy.disable_ai()
	most_recently_spawned_enemy.aiming_master.aim_point = look_marker.global_position
	most_recently_spawned_enemy.target_character = GameMaster.get_player()
	
	recursively_call_init()
	
	
	# Now putting us back inside the spawner after all of our basic pos information
	# is updated
	most_recently_spawned_enemy.global_position = pos_marker.global_position
	

func recursively_call_init(node : Node = most_recently_spawned_enemy):
	for child in node.get_children():
		if child.has_method("init"):
			child.init()
		recursively_call_init(child)


func move_enemy():
	if is_instance_valid(most_recently_spawned_enemy):
		var move_tween = get_tree().create_tween()
		move_tween.tween_property(most_recently_spawned_enemy, "global_position", move_marker.global_position, move_time)
		move_tween.connect("finished", on_finish_move)


func on_finish_move():
	if is_instance_valid(most_recently_spawned_enemy):
		most_recently_spawned_enemy.enable_ai()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_3"):
		spawn()
