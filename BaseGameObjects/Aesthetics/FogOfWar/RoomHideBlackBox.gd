class_name RoomHideBlackBox extends Node3D

@onready var animation_player = $AnimationPlayer

@export var fade_out_time : float = 1.0


func fade_out(fade_time : float = fade_out_time):
	var custom_fade_time = 1.0/fade_time
	animation_player.play("FadeOutBox", -1, custom_fade_time)
