class_name AmmoConsumptionEvent extends RPGEvent

# ----- Parameters ----- #
var gun : Gun
var amount : int

# ----- Modifiers ----- #
var consumption_amount_multiplicative_modifier : float = 1.0
var consumption_amount_additive_modifier : int = 0


func invoke_event():
	var mechanics_master : RPGMechanicsMaster = GameMaster.get_player().rpg_mechanics_master
	mechanics_master.apply_event_modifiers_to_event(self)
	
	var modified_consumption_amount : int = int(floor(amount * consumption_amount_multiplicative_modifier) + consumption_amount_additive_modifier)
	
	gun.current_ammo_count -= modified_consumption_amount
