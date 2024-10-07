class_name PlayerShopInventoryUI extends StorageUI


var hovered_item_domino : ItemDomino = null

# ----- Control Vars ----- #
var item_popup_label : ItemPopupLabel

# ----- Item Name Popup Vars ----- #
var prev_hovered_item_domino : ItemDomino
var hovered_item_domino_time : float = 0.0
const TIME_BEFORE_POPUP_NAME = 0.6	


func _ready():
	super()
	item_popup_label = Util.find_node_by_name(self, "ItemPopupLabel")


func check_hovered():
	return get_global_rect().has_point(get_global_mouse_position())


func update_hovered_item_domino():
	if check_hovered():
		hovered_item_domino = get_item_domino_at_mouse()
	else:
		hovered_item_domino = null


func _process(delta):
	update_hovered_item_domino()
	handle_name_popup(delta)


# --------- Item Name Popup Functions ---------- #

func handle_name_popup(delta : float) -> void:
	if is_instance_valid(item_popup_label):
		if prev_hovered_item_domino != hovered_item_domino:
			close_item_popup_label()
			hovered_item_domino_time = 0.0
		elif not item_popup_label.is_open:
			hovered_item_domino_time += delta        
			if hovered_item_domino_time >= TIME_BEFORE_POPUP_NAME:
				attempt_open_item_popup_label()
				
		prev_hovered_item_domino = hovered_item_domino
		

func attempt_open_item_popup_label():
	if is_instance_valid(hovered_item_domino):
		item_popup_label.assign_item(hovered_item_domino.item)
		item_popup_label.global_position = get_global_mouse_position()
		item_popup_label.open()
	  
  
func close_item_popup_label():
	if item_popup_label:
		item_popup_label.close()
