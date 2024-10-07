extends Camera3D

var shake_fade : float = 0.07
var shake_strength : float = 0.0


func _ready():
	ScreenShakeMaster.screen_shake_requested.connect(apply_shake)


func apply_shake(new_shake_strength : float, force_shake_override : bool, new_shake_fade : float ):
	if force_shake_override or should_new_shake_supercede_old_shake(new_shake_strength, new_shake_fade):
		start_new_shake(new_shake_strength, new_shake_fade)


func start_new_shake(new_shake_strength : float, new_shake_fade : float):
	shake_strength = new_shake_strength
	shake_fade = new_shake_fade


func should_new_shake_supercede_old_shake(new_shake_strength : float, new_shade_fade : float) -> bool:
	return new_shake_strength > shake_strength


func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade)
		
		h_offset = random_offset()
		v_offset = random_offset()
		
	else:
		h_offset = 0
		v_offset = 0
	
	
func random_offset():
	return (randf_range(-shake_strength, shake_strength))
