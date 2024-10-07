class_name LoadoutInfoCard extends Control


var player:Player
var currently_selected_equipment:Item = null

@onready var selected_equipment_card = $SelectedEquipmentCard
@onready var quantity_label:Label = $SelectedEquipmentCard/MarginContainer2/QuantityLabel


func assign_player(new_player : Player):
	player = new_player
	player.inventory.equipped_item_changed.connect(on_equipped_item_changed)
	player.inventory.main_storage.changed.connect(on_inventory_changed)


## Update the equipment image
func on_equipped_item_changed(item:Item) -> void:
	if is_instance_valid(currently_selected_equipment):
		currently_selected_equipment.changed.disconnect(update_quantity)
	
	if not item or item is Gun:
		quantity_label.hide()
	else:
		quantity_label.show()
	
	currently_selected_equipment = item
	if is_instance_valid(currently_selected_equipment):
		currently_selected_equipment.changed.connect(update_quantity)
	selected_equipment_card.build_from_equipment(item)
	update_quantity()


func update_quantity() -> void:
	if is_instance_valid(currently_selected_equipment):
		quantity_label.text = str(player.inventory.find_quantity_of_items_with_id(currently_selected_equipment.item_id))


func on_inventory_changed() -> void:
	update_quantity()
