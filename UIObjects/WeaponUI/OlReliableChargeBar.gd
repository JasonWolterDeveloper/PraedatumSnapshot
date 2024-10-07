class_name OlReliableChargeBar extends Control

## Alt-fire UI element for OlReliable. Displays a series of bars along the circumference of the
## aiming crosshair when alt-fire is held. These bars gradually fill up as the alt-fire is held. 

const BAR_ANGLE:float = deg_to_rad(90) # Each sprite is a quarter-circle
# > 0 means CW; < 0 means CCW. This is to account for the fact that our sprite's "default" rotation
# is -90deg rather than 0deg. 
const ROTATION_OFFSET:float = -PI / 2 
const RADIUS_OFFSET:float = 40

var the_gun:OlReliable
var radius:float = 0
var charge_bars:Dictionary = {} # TextureProgressBar[TextureProgressBar.position]


func _ready():
	for child in get_children():
		if child is TextureProgressBar:
			charge_bars[child] = child.position


func _process(delta):
	var min_radius:float
	var bar_index:int = 0
	var prev_charge_threshold:float = 0

	if is_instance_valid(the_gun):
		position = get_global_mouse_position()
		
		for bar in charge_bars: # Position & fill the bars
			bar.position = charge_bars[bar]
			if radius > RADIUS_OFFSET:
				bar.position += arc_center(ROTATION_OFFSET + bar.rotation + BAR_ANGLE/2) * (radius - RADIUS_OFFSET)
			prev_charge_threshold += the_gun.charge_durations[bar_index - 1] if bar_index > 0 else 0
			bar.value = (the_gun.curr_charge_time - prev_charge_threshold) * 100 \
				 / the_gun.charge_durations[bar_index]
			bar_index += 1


## A helper function that returns the center point of a unit arc given it's angle in radians
func arc_center(angle: float) -> Vector2:
	return Vector2(cos(angle), sin(angle))
