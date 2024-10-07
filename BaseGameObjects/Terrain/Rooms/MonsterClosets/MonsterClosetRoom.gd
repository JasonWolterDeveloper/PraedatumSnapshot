class_name MonsterClosetRoom extends Room


var monster_closet_door : Door
var monster_closet_monsters : Array[Enemy] = []

var room_hide_black_box : RoomHideBlackBox


func _ready():
	super()
	populate_monster_closet_door()
	
	populate_monster_closet_monsters()
	disable_all_monster_ai()
	
	populate_room_hide_black_box()


func populate_monster_closet_door(node = self):
	# Check if the current node is of the desired type
	if node is Door:
		monster_closet_door = node
		return
	
	# Traverse through each child node recursively
	for my_child in node.get_children():
		populate_monster_closet_door(my_child)
		

func populate_room_hide_black_box(node = self):
	# Check if the current node is of the desired type
	if node is RoomHideBlackBox:
		room_hide_black_box = node
		return
	
	# Traverse through each child node recursively
	for my_child in node.get_children():
		populate_room_hide_black_box(my_child)


func populate_monster_closet_monsters(node = self):
		# Check if the current node is of the desired type
	if node is Enemy:
		monster_closet_monsters.append(node)
	
	# Traverse through each child node recursively
	for my_child in node.get_children():
		populate_monster_closet_monsters(my_child)


## Helper Function so we don't have to manually disable every monster we put in
## here
func disable_all_monster_ai():
	for my_monster : Enemy in monster_closet_monsters:
		my_monster.disable_ai()


func activate_monster_closet():
	if room_hide_black_box:
		room_hide_black_box.fade_out()
	if monster_closet_door:
		monster_closet_door.open_door()
	for my_monster : Enemy in monster_closet_monsters:
		my_monster.enable_ai()
		my_monster.show()
