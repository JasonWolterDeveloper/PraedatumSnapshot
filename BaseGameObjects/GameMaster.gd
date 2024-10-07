## Global Singleton for accessing important data like the Level and the Player
## now that we know there definitely will not be more than one Level or Player at
## any given time, this should be useful and more efficient
extends Node


var player : Player
var level : Level



# ---------- Assignment Functions ---------- #

func assign_player(new_player : Player):
	player = new_player
	

func assign_level(new_level : Level):
	level = new_level



# ---------- Getter Functions ---------- #


func get_player():
	if is_instance_valid(player):
		return player
	return null


func get_level():
	if is_instance_valid(level):
		return level
	return null
