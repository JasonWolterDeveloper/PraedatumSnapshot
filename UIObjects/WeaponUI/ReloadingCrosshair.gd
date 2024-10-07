class_name ReloadingCrosshair

extends Control

# The UI element shown during reloading any weapon and what reads the Gun data
# necessary for controlling said UI elements at runtime.

@export var fail_colour:Color = Color(1, 0, 0, 0.65)

var player:Player
var reload_master:
		get: 
			if player.get_equipped_item() is Gun:
				return player.get_equipped_item().reload_master
			return null


func _process(delta):
	var reload_progress:float
	
	if player:
		position = get_global_mouse_position()
		if not player.get_equipped_item() is Gun:
			hide()
			pass
		else:
			$PerfectZone.reload_master = reload_master
			
			if reload_master.is_reloading:
				show()
				reload_progress = reload_master.get_reload_progress()
				$ProgressCircle.value = reload_progress
				$PerfectZone.show()
				if reload_master.reload_failed:
					$ProgressCircle.tint_progress = fail_colour
					$PerfectZone.hide()
				else:
					$ProgressCircle.tint_progress = Color.WHITE
			else:
				hide()
				$ProgressCircle.tint_progress = Color.WHITE


func set_player(new_player : Player):
	assert(new_player)
	player = new_player
