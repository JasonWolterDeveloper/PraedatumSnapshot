class_name RecoilRecoveryEvent extends RPGEvent

# ----- Parameters ----- #
var weapon: Weapon
var delta: float

# ----- Modifiers ----- #
var recoil_recovery_multiplicative_modifier: float = 1.0


func invoke_event():
	var mechanics_master : RPGMechanicsMaster = GameMaster.get_player().rpg_mechanics_master
	mechanics_master.apply_event_modifiers_to_event(self)
	
	var modified_recoil_recovery = weapon.recoil_recovery_per_second * recoil_recovery_multiplicative_modifier
	
	weapon.recoil_spread -= (modified_recoil_recovery * delta)
	weapon.recoil_spread = max(0.0,  weapon.recoil_spread)
