class_name QuestCompass extends Node3D

var compass_mesh : MeshInstance3D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@export var total_display_time : float = 3.0
var current_display_time : float = 0.0

## Save a reference to the quest waypoint that has been requested so we can
## continuously look at it
var current_quest_waypoint : QuestWaypoint

var displaying_compass : bool = false


func _ready():
	compass_mesh = Util.find_node_by_name(self, "CompassMesh")
	QuestSystemMaster.assign_quest_compass(self)


func display_compass_for_waypoint(quest_waypoint : QuestWaypoint):
	current_quest_waypoint = quest_waypoint
	look_at_quest_waypoint(quest_waypoint)
	display_compass()


func display_compass():
	if not displaying_compass:
		show()
		fade_in()
		displaying_compass = true
	current_display_time = 0.0


func undisplay_compass():
	fade_out()
	displaying_compass = false
	current_display_time = 0.0


func fade_in():
	animation_player.play("fade_in")


func fade_out():
	animation_player.play("fade_out")


func look_at_current_quest_waypoint():
	if current_quest_waypoint and is_instance_valid(current_quest_waypoint):
		look_at_quest_waypoint(current_quest_waypoint)


func look_at_quest_waypoint(quest_waypoint : QuestWaypoint):
	var my_look_position = Vector3(quest_waypoint.get_pos().x, global_position.y, quest_waypoint.get_pos().z)
	look_at(my_look_position)


func _process(delta):
	if displaying_compass:
		look_at_current_quest_waypoint()
		current_display_time += delta
		if current_display_time > total_display_time:
			undisplay_compass()
			
