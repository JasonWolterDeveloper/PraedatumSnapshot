extends Control

@onready var utility_amount_label = $UtilityAmountLabel

func update_values_from_player():
	if should_show_ammo_counter():
		show()
		var current_ammo_count = get_player().utility_item.current_quantity
		var max_ammo_count = get_player().utility_item.max_quantity
		
		var ammo_string = str(current_ammo_count) + "/" + str(max_ammo_count)
		
		utility_amount_label.text = ammo_string
	else:
		hide()
			
func should_show_ammo_counter():
	return get_player() and get_player().utility_item and get_player().utility_item.show_quantity_in_ui

func get_level():
	return Util.get_level(self)
	
func get_player():
	return get_level().get_player()	

func _process(delta):
	update_values_from_player()
