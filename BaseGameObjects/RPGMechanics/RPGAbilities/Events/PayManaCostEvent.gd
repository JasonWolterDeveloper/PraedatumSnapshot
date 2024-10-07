class_name PayManaCostEvent extends RPGEvent

var mana_cost_payer : Character
var mana_cost : float
var mana_cost_multiplicative_modifier : float = 1.0
var mana_cost_additive_modifier : float = 0.0

func invoke_event():
	if mana_cost_payer:
		mana_cost_payer.rpg_mechanics_master.apply_event_modifiers_to_event(self)
	
		var modified_mana_cost : float = mana_cost * mana_cost_multiplicative_modifier + mana_cost_additive_modifier
		var final_mana_cost = max(modified_mana_cost, 0)
		mana_cost_payer.rpg_mechanics_master.mana.decrease_stat(modified_mana_cost)
	super()
