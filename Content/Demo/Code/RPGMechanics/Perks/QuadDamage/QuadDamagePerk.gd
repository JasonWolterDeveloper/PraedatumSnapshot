class_name QuadDamagePerk extends RPGPerk

@export var multiplier = 4.0
@onready var timer = $Timer

# duration in seconds
@export var duration = 1.0

var quad_damage_on = false

func activate():
	super()
	DebugMaster.log_debug("We really do be having quad damage")
	quad_damage_on = true
	
	# Create a Timer node
	timer.wait_time = duration
	# Start the timer
	timer.start()
	
func timer_end():
		DebugMaster.log_debug("No more quad")
		quad_damage_on = false
		
func activation_conditions() -> bool:
	return not quad_damage_on and super()

func apply_perk_effect(rpg_event : RPGEvent):
	super(rpg_event)
	if rpg_event is DamageEvent and quad_damage_on:
		rpg_event.damage_amount = multiply_value(rpg_event.damage_amount, multiplier)
	return
