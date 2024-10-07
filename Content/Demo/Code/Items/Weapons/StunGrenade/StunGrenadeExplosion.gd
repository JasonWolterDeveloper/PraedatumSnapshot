class_name StunGrenadeExplosion extends Explosion

@export var stun_effect_scene: PackedScene


func apply_to_character(character : Character):
	super(character)
	
	var stun_effect = stun_effect_scene.instantiate()
	character.rpg_mechanics_master.add_status_effect(stun_effect)
