class_name QuestWaypoint extends Node3D

@export var id : String


func _ready():
	QuestSystemMaster.add_quest_waypoint(self)


func get_pos():
	return global_position
