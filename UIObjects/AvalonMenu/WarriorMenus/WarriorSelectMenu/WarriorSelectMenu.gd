class_name WarriorSelectMenu extends Control

@export var warrior_selection_element_scene : PackedScene

var warrior_menu : WarriorMenu = null
var warrior_selections : Control


func _ready():
	warrior_selections = Util.find_node_by_name(self, "WarriorSelections")
	update()


func assign_warrior_menu(new_warrior_menu : WarriorMenu):
	warrior_menu = new_warrior_menu


func clear_warrior_selections():
	for child in warrior_selections.get_children():
		if child is WarriorSelectionElement:
			warrior_selections.remove_child(child)
			child.queue_free()


func add_warrior_selection_element_for_warrrior(warrior : Warrior):
	var warrior_selection_element : WarriorSelectionElement = warrior_selection_element_scene.instantiate()
	warrior_selections.add_child(warrior_selection_element)
	warrior_selection_element.assign_warrior(warrior)
	warrior_selection_element.warrior_changed.connect(on_warrior_changed)


func on_warrior_changed():
	update()
	if warrior_menu:
		warrior_menu.on_warrior_changed()


func update():
	clear_warrior_selections()
	for warrior_id in WarriorMaster.warrior_dictionary.keys():
		add_warrior_selection_element_for_warrrior(WarriorMaster.warrior_dictionary[warrior_id])
