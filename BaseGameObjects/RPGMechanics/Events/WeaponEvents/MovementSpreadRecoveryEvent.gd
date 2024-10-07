class_name MovementSpreadRecoveryEvent extends RPGEvent

# ----- Parameters ----- #
var weapon: Weapon
var delta: float

# ----- Modifiers ----- #
var movement_spread_recovery_multiplicative_modifier: float = 1.0


func invoke_event():
	var player : Player = GameMaster.get_player()
	if player:
		var mechanics_master : RPGMechanicsMaster = player.rpg_mechanics_master
		mechanics_master.apply_event_modifiers_to_event(self)
		
		var modified_spread_recovery = weapon.movement_spread_recovery_per_second * movement_spread_recovery_multiplicative_modifier

		weapon.movement_spread -= (modified_spread_recovery * delta)
		weapon.movement_spread = max(0, weapon.movement_spread)
