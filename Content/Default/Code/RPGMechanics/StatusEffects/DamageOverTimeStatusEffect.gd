class_name DamageOverTimeStatusEffect extends RPGStatusEffect

@export var damage_per_second : float = 1.0
var origin_character : Character = null 


func calculate_damage_amount(delta: float):
	return delta*damage_per_second


func apply_periodic_effect(delta : float):
	super(delta)
	
	RPGEventMaster.invoke_damage_event(calculate_damage_amount(delta), get_character(), origin_character)
