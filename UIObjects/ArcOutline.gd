class_name ArcOutline extends Control

## Control utility scene for drawing arc outlines / "hollow" coloured arcs. By default, the polygon 
## is only constructed once, meaning that changes in geometry vars are not reflected every frame
## unless desired otherwise.
##
## Remember to set Control instance vars scale, rotation, & position. Optionally, 
## use_clock_transform moves the ArcOutline as if it were an arm on a clock; this can be used as an
## alternative to setting Control.rotation & Control.position.


# Updates are not reflected every frame, unless desired:
var force_geometry_update:bool = false ## Should the polygon should be generated every frame?
 ## Arc's (geometry) angle in radians. Use Control.rotation for rotation
var angle:float = PI / 2
var quality:int = 15 ## Number of vertexes. Is rounded up to the nearest even number
## What proportion of the total thickness is comprised of the outline. From 0.0 to 1.0
var outline_thickness_factor:float = 0.15


# Updates are reflected every frame:
var use_aa:bool = true ## Antialiasing
var colour:Color ## Applies uniformly to the entire polygon
var use_clock_transform:bool = false ## Moves the ArcOutline like a clock hand around an specified point
var clock_arm_length:float

# Private Vars:
@onready var outline_poly:PackedVector2Array

# ----------------------------------------------- BUILT-IN METHODS


func _process(delta):
	if not outline_poly or force_geometry_update: # Initialize the poly
		pivot_offset = Vector2(arc_center(angle/2.0))
		outline_poly = create_outline_poly()
	queue_redraw()

# ----------------------------------------------- PRIVATE METHODS

func _draw():
	if outline_poly:
		if use_clock_transform:
			position =  clock_arm_length * arc_center(rotation + angle / 2.0) 
		
		draw_polyline(outline_poly, colour, outline_thickness_factor/2, use_aa)


## A helper function that returns the center point of a unit arc given it's angle in radians
func arc_center(angle: float) -> Vector2:
	return Vector2(cos(angle), sin(angle))


## Creates a unit polygon for the arc outline (imagine a slice of a doughnut). First, a (unit) 
## reference arc is constructed, then a large arc above and a small one below which are connected to 
## form the outline arc poly. This resulting poly is normalized and must be transformed 
## (scaled, rotated, etc) appropiately in _draw()
func create_outline_poly() -> PackedVector2Array:
	# Need to construct the desired poly before passing it to perfect_poly.polygon, since
	# Polygon2D.polygon is accessed BY VALUE rather by reference like a normal fucking member >:(
	var poly_point_array := PackedVector2Array() 
	var poly_point : Vector2

	# For calculating small and large arcs:
	var unit_arc := PackedVector2Array()
	var arc_radius_delta:float = (2 - outline_thickness_factor) / 4.0
	var curr_angle = 0
	var arc_num_points:int = ceil(quality/2.0) 
	
	# Calculate a unit arc for reference:
	for i in arc_num_points: 
		unit_arc.append(Vector2(cos(curr_angle), sin(curr_angle)))
		curr_angle += angle / (arc_num_points - 1)
	
	
	# Large arc is unit_arc:
	for i in range(-1, 2, 2): # [-1, 1]: determines if we add or subtract arc_radius_delta
		for unit_vector in unit_arc:
			poly_point = unit_vector * (1 + i * arc_radius_delta)
			poly_point.normalized()
			poly_point_array.append(poly_point)
		unit_arc.reverse() # Necessary to connect the small and large arcs
	poly_point_array.append(poly_point_array[0])

	return poly_point_array
