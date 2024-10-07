class_name StatSegmentOverlayControl extends Control

# ----- Control References ----- #
# Exported reference to the packed scene of type SegmentSeparator
@export var segment_separator_control_scene: PackedScene

# HBoxContainer node to hold segments
var separator_container: HBoxContainer

# Reference to the health bar Control node
var health_bar: HealthBar

# ----- Tracking Variables ----- #
var custom_spacer_width : float = 0.0



# ---------- Ready and Assignment Functions ---------- #


func _ready():
	separator_container = Util.find_node_by_name(self, "SeparatorContainer")


func assign_health_bar(new_health_bar: HealthBar):
	health_bar = new_health_bar
	update()



# ---------- Update Functions ---------- #


# Function to update the segments based on the stat
func update():
	# Clear existing children
	Util.delete_all_children(separator_container)
	
	if health_bar and health_bar.get_number_of_segments() > 1:
		custom_spacer_width = health_bar.calculate_physical_stat_segment_length()
		
		for x in range(health_bar.get_number_of_segments() - 1):
			var new_custom_spacer : Control = generate_custom_spacer()
			var new_separator : Control = segment_separator_control_scene.instantiate()
			separator_container.add_child(new_custom_spacer)
			separator_container.add_child(new_separator)



# ---------- Helper Functions ---------- #


func generate_custom_spacer() -> Control:
	var custom_spacer = Control.new()
	custom_spacer.custom_minimum_size.x = custom_spacer_width
	custom_spacer.size.x = custom_spacer_width
	
	return custom_spacer
