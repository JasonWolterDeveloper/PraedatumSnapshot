class_name TrenchMace extends MeleeWeapon

@export var stun_effect_scene : PackedScene


func handle_basic_hit(my_hitbox: hitbox):
	super(my_hitbox)
	
	var stun_effect = stun_effect_scene.instantiate()
	my_hitbox.get_character().rpg_mechanics_master.add_status_effect(stun_effect)
