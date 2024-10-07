class_name PlayerDamagedAestheticEffect extends Node


@export var has_screen_shake : bool = true
@export var screen_shake_amount : float = 0.2

@export var has_damage_vignette : bool = true
@export var damage_vignette_amount : float = 0.7
@export var damage_vignette_duration : float = 0.3


func play_damage_effect():
	if has_screen_shake:
		ScreenShakeMaster.request_screen_shake(screen_shake_amount)
	if has_damage_vignette:
		VignetteMaster.request_damage_vignette(damage_vignette_amount, damage_vignette_duration)
