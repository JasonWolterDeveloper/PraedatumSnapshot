extends Control

@onready var basic_damage_vignette = $BasicDamageVignette
@onready var basic_gunshot_vignette = $BasicGunshotVignette
var damage_vignette_tween : Tween
var gunshot_vignette_tween : Tween


func tween_vignette(vignette : Control, vignette_tween : Tween, starting_value : float, duration : float):
	vignette.modulate.a = starting_value
	vignette_tween.tween_property(vignette, "modulate:a", 0, duration)


func check_should_replace_current_damage_vignette(starting_value: float):
	return starting_value > basic_damage_vignette.modulate.a


func check_should_replace_current_gunshot_vignette(starting_value: float):
	return starting_value > basic_gunshot_vignette.modulate.a


func end_vignette(vignette : TextureRect, vignette_tween : Tween):
	if vignette_tween:
		vignette_tween.kill()
	vignette.modulate.a = 0


func end_basic_damage_vignette_tween():
	end_vignette(basic_damage_vignette, damage_vignette_tween)


func end_basic_gunshot_vignette_tween():
	end_vignette(basic_gunshot_vignette, gunshot_vignette_tween)


func tween_basic_damage_vignette(starting_value : float, duration : float):
	# If we have an exiting damage vignette we should get rid of it
	end_basic_damage_vignette_tween()
	
	# Damage Vignettes are straight up higher priority than gunshot vignettes
	# so we get rid of it here
	end_basic_gunshot_vignette_tween()
	
	damage_vignette_tween = get_tree().create_tween()
	tween_vignette(basic_damage_vignette, damage_vignette_tween, starting_value, duration)


func tween_basic_gunshot_vignette(starting_value : float, duration: float):
	# If we already have a gunshot we want to get rid of it
	end_basic_gunshot_vignette_tween()
	
	gunshot_vignette_tween = get_tree().create_tween()
	tween_vignette(basic_gunshot_vignette, gunshot_vignette_tween, starting_value, duration)


func request_damage_vignette(starting_value : float, duration : float):
	if check_should_replace_current_damage_vignette(starting_value):
		tween_basic_damage_vignette(starting_value, duration)


func request_gunshot_vignette(starting_value : float, duration : float):
	if check_should_replace_current_gunshot_vignette(starting_value):
		tween_basic_gunshot_vignette(starting_value, duration)
