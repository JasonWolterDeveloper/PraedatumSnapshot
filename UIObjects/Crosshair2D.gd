extends Sprite2D

var crosshair_radius = 5
	
func _draw():
	var circle_center = get_global_mouse_position()
	draw_arc(circle_center, crosshair_radius, 0, 2*PI, 360, Color(0, 0, 0), 4.0, true)
	draw_arc(circle_center, crosshair_radius, 0, 2*PI, 360, Color(255, 255, 255), 2.0, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
