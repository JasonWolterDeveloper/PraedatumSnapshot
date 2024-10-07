class_name PerfectZone extends Control

## Exclusively controls the drawing of the reload perfect zone arc. The arc is rotated and translated
## such that it lies along the circumference of an imaginary circle, our in our case, the reload 
## progress circle.

@export var colour:Color = Color(0, 0.75, 0, 0.5)
@export var thickness:float = 18
@export var quality:int = 15 ## Number of points in the arc
@export var use_aa:bool = true ## Antialiasing
@export var ref_circle_radius:float = 46

var reload_master:ReloadMaster ## Set by parent

var arc_angle:float

func _process(delta):
	if is_instance_valid(reload_master):
		arc_angle = (2*PI) * reload_master.modified_perfect_zone_length # Radians
		pivot_offset = Vector2(arc_center(arc_angle/2.0)) # For scale & rotation
		queue_redraw()


func _draw():
	if is_instance_valid(reload_master):
		rotation = (2 * PI) * reload_master.perfect_zone_pos
		position = arc_center(rotation + arc_angle / 2.0)
		draw_arc(Vector2.ZERO, ref_circle_radius, 0, arc_angle, quality, colour, thickness, use_aa)


## A helper function that returns the center point of a unit arc given it's angle in radians
func arc_center(angle: float) -> Vector2:
	return Vector2(cos(angle), sin(angle))
