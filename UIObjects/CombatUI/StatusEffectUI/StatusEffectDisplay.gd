class_name StatusEffectDisplay extends Sprite3D

## A simple class that serves as the UI for applied status effects. It expires, so be sure to use
## null-safe queue_free() when referring to this class externally.

@export var text:String = "" ## Text to be displayed
@export var animation_speed:float = 0.5 ## How quicly the text rises in m/s
@export var lifetime:float = 1.5 ## Number of seconds before we delete ourselves

var time_alive:float = 0.0

@onready var text_label = Util.find_node_by_name(self, "RichTextLabel")


func _ready() -> void:
	text_label.text = "[center]" + text


func _process(delta):
	global_position.y += animation_speed * delta
	time_alive += delta
	
	if time_alive >= lifetime:
		queue_free()
