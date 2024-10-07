class_name RPGStatusEffect extends Node3D

@export var periodic_effect : bool = false
@export var period_length : float = 1.0
var current_period_length : float = 0.0

@export var timed_effect : bool = true
@export var duration : float = 1.0
var current_duration : float = 0.0

var rpg_mechanics_master : RPGMechanicsMaster

@export var rpg_stat_modifiers : Array[RPGStatModifier] = []
@export var rpg_event_modifiers : Array[RPGEventModifier] = []

@export var id : String = ""

@export_multiline var added_text:String = ""
@export var added_text_duration:float = -1 ## Uses default duration if negative
@export var show_added_text_for_refresh:bool = false
@export_multiline var removed_text:String = "" ## Currently unused
@export var removed_text_duration:float = -1 ## Uses default duration if negative

func _physics_process(delta):
	if periodic_effect:
		apply_periodic_effect(delta)
		"""
		current_period_length += delta
		if current_period_length >= period_length:
			current_period_length = 0.0
			apply_periodic_effect(delta)
			"""
			
	if timed_effect:
		current_duration += delta
		if current_duration >= duration:
			destroy_status_effect()


func reset_timer():
	current_duration = 0.0


func destroy_status_effect():
	rpg_mechanics_master.destroy_status_effect(self)


func apply_periodic_effect(delta : float):
	pass


func apply_to_event(event: RPGEvent):
	pass
	
  
func apply_to_stat(stat: RPGStat):
	pass
	

func on_status_effect_added() -> void:
	dispaly_effect_text(added_text, added_text_duration)


func on_status_effect_removed() -> void:
	dispaly_effect_text(removed_text, removed_text_duration)


func assign_rpg_mechanics_master(new_rpg_mechanics_master: RPGMechanicsMaster):
	rpg_mechanics_master = new_rpg_mechanics_master


func get_character() -> Character:
	if rpg_mechanics_master:
		return rpg_mechanics_master.character
	return null


func dispaly_effect_text(text:String, duration:float) -> void:
	if duration > 0:
		rpg_mechanics_master.character.display_status_effect_text(text, duration)
	else:
			rpg_mechanics_master.character.display_status_effect_text(text)
