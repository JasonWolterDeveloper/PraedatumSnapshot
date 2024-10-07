extends Node

var default_shake_fade : float = 0.07

signal screen_shake_requested


func request_screen_shake(new_shake_strength : float, force_shake_override : bool = false, new_shake_fade : float = default_shake_fade):
	screen_shake_requested.emit(new_shake_strength, force_shake_override, new_shake_fade)
