class_name HealthBar extends Control

var current_percent : float = 100.0 # The Current 
var stat_to_watch : RPGStat

# ----- Configurable Properties ----- #
## Tween_time is the speed at which the damage_bar catches up to the top_health_bar
## expressed as the total amount of time it would take to tween the whole length
## of the bar. The higher the time, the lower the speed
@export var tween_time: float = 1.0
## dynamic_length boolean indicates that we should change our length based onthe max value
## of the stat
@export var dynamic_length : bool = false
## length_to_max_value ratio is the amount of pixels each unit of max value should
## increase the bar by
@export var length_to_max_value_ratio : float = 1.0
## max_length is the maximum length we can resize to
@export var max_length : float = 500.0

## time_to_update_damage_bar is the amount of tiem it takes the damage bar to actually start
## lowering after a successful hit
@export var time_to_update_damage_bar : float = 0.2

# ----- Control References ----- #
var damage_bar : ProgressBar
var top_health_bar : ProgressBar
var timer : Timer
var tween : Tween
var stat_segment_overlay : StatSegmentOverlayControl
# bar container contains everything in the actual health bar itself. This is because
# we want to be able to hide it if we show the no stat label
var bar_container : Container
var no_stat_label : Label



# ---------- Ready and Assignment Functions ---------- #


func _ready() -> void:
	damage_bar = Util.find_node_by_name(self, "DamageBar")
	top_health_bar = Util.find_node_by_name(self, "TopHealthBar")
	timer = Util.find_node_by_name(self, "Timer")
	stat_segment_overlay = Util.find_node_by_name(self, "StatSegmentOverlayControl")
	bar_container = Util.find_node_by_name(self, "BarContainer")
	no_stat_label = Util.find_node_by_name(self, "NoStatLabel")


func assign_stat(new_stat_to_watch : RPGStat):
	if is_instance_valid(stat_to_watch):
		stat_to_watch.changed.disconnect(on_stat_changed)
	
	stat_to_watch = new_stat_to_watch
	
	if stat_to_watch:
		# We have a stat so we want to show ourselves
		bar_container.show()
		no_stat_label.hide()
		
		stat_to_watch.changed.connect(on_stat_changed)

		initialize_values_from_stat()
		if stat_segment_overlay:
			stat_segment_overlay.assign_health_bar(self)
			stat_segment_overlay.update()
	else:
		# We do not have a stat so we want to hide ourselves
		bar_container.hide()
		no_stat_label.show()


func initialize_values_from_stat():
	if stat_to_watch:
		damage_bar.value = stat_to_watch.calculate_percent_full()
		top_health_bar.value = stat_to_watch.calculate_percent_full()
		
		update_length()



# ----------- Update Functions ---------- #


func on_stat_changed():
	if stat_to_watch:
		update_length()
		# Updating background values
		var prev_percent : float = current_percent
		current_percent = stat_to_watch.calculate_percent_full()
		
		# Updating actual health bar
		top_health_bar.value = current_percent
		
		# Handling Damange_Bar situations
		if prev_percent < current_percent:
			damage_bar.value = current_percent
		else:
			# We've taken damage so we show ourselves
			show()
			timer.start(time_to_update_damage_bar)
		
		if stat_segment_overlay:
			stat_segment_overlay.update()


func update_length():
	if dynamic_length and stat_to_watch:
		var new_length: float = min(max_length, stat_to_watch.get_max_value() * length_to_max_value_ratio)
		custom_minimum_size.x = new_length


func _on_timer_timeout() -> void:
	if tween:
		tween.kill()
	
	if damage_bar.value > current_percent:
		tween = create_tween()
		var difference = damage_bar.value - current_percent
		tween.tween_property(damage_bar, "value", current_percent, calculate_tween_time(difference))



# --------- Helper Functions ---------- #


func calculate_tween_time(difference : float) -> float:
	return difference/100.0 * tween_time


## Calculates the physical on screen length of a stat segment by calculating what percentage
## of the total value of the stat a single segment takes up and then multiplying the physical
## on screen length of the healthbar by that number
func calculate_physical_stat_segment_length() -> float:
	if stat_to_watch is RPGSegmentedStat:
		var segment_model_length : float = stat_to_watch.value_per_segment
		var stat_total_length : float = stat_to_watch.get_max_value()
		var segment_percent_of_total_length : float = segment_model_length/stat_total_length
		
		var segment_physical_length : float = get_physical_health_bar_length() * segment_percent_of_total_length
		
		return segment_physical_length
	return 0.0



# --------- Getters and Setters Functions ---------- #


func get_number_of_segments() -> int:
	if stat_to_watch is RPGSegmentedStat:
		return stat_to_watch.number_of_segments
	return 1


func get_physical_health_bar_length() -> float:
	if top_health_bar:
		top_health_bar.update_minimum_size()
		return top_health_bar.size.x
	return 0.0



# ---------- Signal Connections ---------- #


# Resizing the health bar can cause changes in the size of the segment overlay, 
# so we update it here if that is the case
func _on_top_health_bar_resized() -> void:
	if stat_segment_overlay:
		stat_segment_overlay.update()
