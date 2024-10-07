class_name RecoilEvent extends RPGEvent

# ----- Parameters ----- #
var weapon: Weapon
var recoil_amount: float

# ----- Modifiers ----- #
var recoil_multiplicative_modifier: float = 1.0


func invoke_event():
	var mechanics_master : RPGMechanicsMaster = GameMaster.get_player().rpg_mechanics_master
	mechanics_master.apply_event_modifiers_to_event(self)
	
	var modified_recoil = recoil_amount * recoil_multiplicative_modifier
	
	# Assuming weapon has a recoil spread value that we need to modify
	weapon.recoil_spread += modified_recoil
	weapon.recoil_spread = min(weapon.recoil_spread, weapon.maximum_recoil_spread)
