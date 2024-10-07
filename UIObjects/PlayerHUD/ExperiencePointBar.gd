extends Control

# Necessary UI Elements #
var progress_bar : ProgressBar

# Necessary Model Variables
var warrior : Warrior


func _ready():
	progress_bar = Util.find_node_by_name(self, "ProgressBar")


func assign_warrior(new_warrior : Warrior):
	if is_instance_valid(warrior):
		warrior.experience_points_changed.disconnect(update)
	warrior = new_warrior
	warrior.experience_points_changed.connect(update)
	update()


func attempt_assign_warrior():
	if not is_instance_valid(warrior) and WarriorMaster.get_selected_warrior():
		assign_warrior(WarriorMaster.get_selected_warrior())


func update():
	progress_bar.value = warrior.calculate_progress_to_next_level_as_percentage()
	

func _physics_process(delta):
	attempt_assign_warrior()
