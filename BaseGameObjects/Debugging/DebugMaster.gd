extends Node

const LOG_FILE_NAME = "res://log.txt"

@onready var message_box = $CanvasLayer/MessageBox

enum {DEBUG_CATEGORY_OFF, DEBUG_CATEGORY_SCREEN, DEBUG_CATEGORY_LOG, DEBUG_CATEGORY_BOTH}
const LOG_FILE_FORMAT_STRING = "[%s] | <%s> | %s"
var log_file = null

const DEBUG_MESSAGE_BOX_MASTER_ARM = false
const CONSOLE_LOG_MASTER_ARM = false
const LOG_FILE_MASTER_ARM = true

# Debug Categories

const DEFAULT_DEBUG_CATEGORY = ["Default", DEBUG_CATEGORY_BOTH]
const INVENTORY_DEBUG_CATEGORY = ["Inventory", DEBUG_CATEGORY_LOG]
const WEAPON_DEBUG_CATEGORY = ["Weapon", DEBUG_CATEGORY_BOTH]
const SAVE_DEBUG_CATEGORY = ["Save", DEBUG_CATEGORY_LOG]
const AI_DEBUG_CATEGORY = ["AI", DEBUG_CATEGORY_SCREEN]

# End Debug Categories

func _ready():
	log_file = FileAccess.open(LOG_FILE_NAME, FileAccess.WRITE)
	
func log_debug(text, debug_category=DEFAULT_DEBUG_CATEGORY):
	var on_screen_string = str(text)
	
	if CONSOLE_LOG_MASTER_ARM:
		print(on_screen_string)
		
	if LOG_FILE_MASTER_ARM:
		if debug_category[1] == DEBUG_CATEGORY_LOG or debug_category[1] == DEBUG_CATEGORY_BOTH:
			var time_stamp = Time.get_time_string_from_system()
			var category_stamp = debug_category[0]
			var log_string = LOG_FILE_FORMAT_STRING % [time_stamp, category_stamp, on_screen_string]
			log_file.store_line(log_string)
	
	if DEBUG_MESSAGE_BOX_MASTER_ARM:
		if debug_category[1] == DEBUG_CATEGORY_SCREEN or debug_category[1] == DEBUG_CATEGORY_BOTH:
			message_box.add_message(on_screen_string)
	
func on_quit():
	log_file.close()
