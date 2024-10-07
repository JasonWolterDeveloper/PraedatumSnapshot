extends Control

@onready var ammo_amount_label = $AmmoAmountLabel

func update_values_from_player():
	if should_show_ammo_counter():
		show()
		var current_ammo_count = get_player().get_equipped_item().get_current_ammo_count()
		var max_ammo_count = get_player().get_equipped_item().get_max_ammo_count()
		
		var ammo_string = str(current_ammo_count) + "/" + str(max_ammo_count)
		
		ammo_amount_label.text = ammo_string
	else:
		hide()
			
func should_show_ammo_counter():
	return get_player() and get_player().get_equipped_item() is Gun

func get_level():
	return Util.get_level(self)
	
func get_player():
	return get_level().get_player()	

func _process(delta):
	update_values_from_player()
