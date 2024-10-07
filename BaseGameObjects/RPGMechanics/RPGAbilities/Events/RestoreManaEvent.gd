class_name RestoreManaEvent extends RPGEvent

var mana_restore : float
var mana_restore_multiplicative_modifier : float = 1.0
var mana_restore_additive_modifier : float = 0.0


func invoke_event():
	# Only the Player has mana so we don't bother making this a modifiable variable
	var player : Player = GameMaster.get_player()
	if player:
		player.rpg_mechanics_master.apply_event_modifiers_to_event(self)
		var modified_mana_restore : float = mana_restore * mana_restore_multiplicative_modifier + mana_restore_additive_modifier
		var final_mana_restore = max(modified_mana_restore, 0)
		player.rpg_mechanics_master.mana.increase_stat(final_mana_restore)
	super()
