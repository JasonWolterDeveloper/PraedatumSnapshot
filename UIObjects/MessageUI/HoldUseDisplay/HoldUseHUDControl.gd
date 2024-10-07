class_name HoldUseHUDControl extends Control

# ----- Control Variables ----- #
var use_label : Label
var progress_bar : ProgressBar

# ----- Tracking Variables ----- #
var current_display_priority : int = 1
var display_requested : bool = false


# --------- Ready and Assignemnt Functions --------- #

func _ready():
	use_label = Util.find_node_by_name(self, "UseLabel")
	progress_bar = Util.find_node_by_name(self, "ProgressBar")


## Takes progress, which should be a float between 0.0 and 100 representing the
## percentage completed the interaction is, and a display_text which is a string to
## display while interacting. Priority indicates whether or not we should override
## previous requests
func request_display_progress(progress : float, display_text  : String, priority : int = 1):
	display_requested = true
	show()
	
	if not display_requested or priority >= current_display_priority:
		current_display_priority = priority
		progress_bar.value = progress
		use_label.text = display_text


# --------- Update and Process Functions --------- #

func _process(delta: float) -> void:
	if not display_requested:
		hide()
	else:
		display_requested = false
