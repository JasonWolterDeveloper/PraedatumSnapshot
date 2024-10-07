extends State

# Look back and forth along a "pie segment"

@export var angular_speed_deg:float = 45 # Speed of head turn [deg/sec]
@export var scan_angle_deg:float = 45 # Angle of head turn [deg]
@export var pause_time:float = 2 # Time between head turns [sec]

@onready var timer:Timer = $Timer

var start_angle:float # [rad]
var angular_velocity:float # [rad/sec]


func on_entry(phys_delta) -> bool:
	super(phys_delta)
	start_angle = my_character.global_rotation.y
	angular_velocity = -deg_to_rad(angular_speed_deg)
	timer.wait_time = randf_range(0, pause_time) # Prevents characters from scanning in unison
	timer.start()
	
	return true # One-shot routine


func on_active(phys_delta) -> bool:
	super(phys_delta)
	var is_outside_segment:bool
	
	if timer.is_stopped():
		# Reached an end of the seek "pie segment": pause and reverse seek direction:
		is_outside_segment = my_character.global_rotation.y <= start_angle \
				or my_character.global_rotation.y >= (start_angle + deg_to_rad(scan_angle_deg))
				
		if is_outside_segment:
			angular_velocity *= -1
			timer.wait_time = pause_time
			timer.start()
			
		# Remember, states are updated on physics frames only:
		my_character.global_rotation.y += angular_velocity * get_physics_process_delta_time()
		
	return false # Continuous routine
