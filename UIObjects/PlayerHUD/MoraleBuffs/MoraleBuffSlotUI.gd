## Tracks all UI information for a single morale buff slot
class_name MoraleBuffSlotControl extends Control


# ----- Model References ----- #
@export var morale_buff_slot_index : int = 0
var morale_buff_master : MoraleBuffMaster

# ----- Control References ----- #
var progress_bar : ProgressBar
var morale_buff_image : TextureRect



# ---------- Ready and Assignment Functions ---------- #


func _ready():
	progress_bar = Util.find_node_by_name(self, "ProgressBar")
	morale_buff_image = Util.find_node_by_name(self, "MoraleBuffImage")


func assign_player(player : Player) -> void:
	assign_morale_buff_master(player.rpg_mechanics_master.morale_buff_master)


func assign_morale_buff_master(new_morale_buff_master : MoraleBuffMaster) -> void:
	morale_buff_master = new_morale_buff_master



# --------- Update Functions --------- #


func update():
	if morale_buff_master:
		if morale_buff_master.get_total_morale_buff_slots() <= morale_buff_slot_index:
			hide()
		else:
			var morale_buff : MoraleBuff = morale_buff_master.get_buff_for_slot_index(morale_buff_slot_index)
			if morale_buff:
				progress_bar.value = morale_buff.get_percent_time_left()
				morale_buff_image.texture = morale_buff.ui_image
			else:
				progress_bar.value = 0.0
				morale_buff_image.texture = null
			show()


func _process(delta):
	update()
