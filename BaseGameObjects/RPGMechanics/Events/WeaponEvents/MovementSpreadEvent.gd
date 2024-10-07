class_name MovementSpreadEvent extends RPGEvent

# ----- Parameters ----- #
var weapon: Weapon
var delta: float

# ----- Modifiers ----- #
var movement_spread_multiplicative_modifier: float = 1.0
var maximum_movement_spread_multiplicative_modifier: float = 1.0
var maximum_walking_movement_spread_multiplicative_modifier: float = 1.0


func invoke_event():
	var player : Player = GameMaster.get_player()
	if player:
		var mechanics_master : RPGMechanicsMaster = player.rpg_mechanics_master
		mechanics_master.apply_event_modifiers_to_event(self)
		
		var modified_movement_spread = weapon.movement_spread_gain_per_second * movement_spread_multiplicative_modifier
		var modified_maximum_movement_spread = weapon.maximum_movement_spread * maximum_movement_spread_multiplicative_modifier
		
		if player.movement_master.walking:
			modified_maximum_movement_spread = weapon.maximum_walking_movement_spread * maximum_walking_movement_spread_multiplicative_modifier
			
		weapon.movement_spread += (modified_movement_spread * delta)
		weapon.movement_spread = min(modified_maximum_movement_spread, weapon.movement_spread)
