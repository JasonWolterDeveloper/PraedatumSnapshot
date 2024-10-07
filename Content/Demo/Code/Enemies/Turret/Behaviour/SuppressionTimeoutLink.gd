class_name SuppressionTimeoutLink extends Link

var timeout_time : float = 5.0
@export var random_timeout_max : float = 8.0
@export var random_timeout_min : float = 5.0
@export var turret_ranged_engage_state : TurretRangedEngageFSM
var current_timeout_time : float = 0.0


func is_triggered():
	if current_timeout_time > timeout_time:
		current_timeout_time = 0
		return true
	return false


func _process(delta):
	if turret_ranged_engage_state:
		if turret_ranged_engage_state.current_state == turret_ranged_engage_state.suppression_state:
			current_timeout_time += delta
			return
	current_timeout_time = 0


func on_entry():
	timeout_time = randf_range(random_timeout_min, random_timeout_max)
	current_timeout_time = 0
