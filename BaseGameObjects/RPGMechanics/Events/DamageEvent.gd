class_name DamageEvent extends RPGEvent

# ----- Parameters ----- #
var damager_character : Character = null
var damaged_character : Character = null
var damage_amount : float = 0
var weapon : Weapon = null
var bullet : Bullet = null

# ----- Modifiers ----- #
var damage_multiplicative_modifier : float = 1.0
var damage_additive_modifier : float = 0.0

var immune_to_damage : bool = false
var should_use_armour = true
var should_notify_ai_of_damager : bool = true


func invoke_event():
	if is_instance_valid(damaged_character):
		damaged_character.rpg_mechanics_master.apply_event_modifiers_to_event(self)
		
		if is_instance_valid(damager_character):
			damager_character.rpg_mechanics_master.apply_event_modifiers_to_event(self)
			
		if is_instance_valid(weapon):
			weapon.apply_event_modifiers_to_event(self)
		
		if is_instance_valid(bullet):
			bullet.apply_event_modifiers_to_event(self)
		
		
		if not immune_to_damage:
			var modified_damage_amount : float = damage_amount * damage_multiplicative_modifier + damage_additive_modifier
			var final_damage_amount = max(modified_damage_amount, 0)
			
			# DebugMaster.log_debug("Attempting to deal: " + str(final_damage_amount) + " To the enemy")
			
			var armour:Armour = damaged_character.armour
		
			if should_use_armour and armour: # Decrease health damage if armour absorbed any
				var armour_overflow:float = armour.take_damage(final_damage_amount * armour.damage_absorbtion)
				if armour_overflow:
					pass
				final_damage_amount *= (1 - armour.damage_absorbtion)
				final_damage_amount += armour_overflow
			
			damaged_character.rpg_mechanics_master.health.decrease_stat(final_damage_amount)
			damaged_character.rpg_mechanics_master.damage_event_signal.emit(self)
			#DebugMaster.log_debug("did " + str(final_damage_amount) + " damage to ")
			
			if damaged_character.rpg_mechanics_master.health.get_current_health() == 0 and not damaged_character.dead:
				damaged_character.on_death()
		else:
			OnScreenMessageMaster.display_message("You are Divinely Protected")
	super()
