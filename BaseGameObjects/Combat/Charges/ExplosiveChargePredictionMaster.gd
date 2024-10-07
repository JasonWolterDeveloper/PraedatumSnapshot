class_name ExplosiveChargePredicitonMaster extends Node3D

@onready var effect_radius : MeshInstance3D = $EffectRadius
@onready var area_of_effect_indicator : AreaOfEffectIndicator = $AreaOfEffectIndicator

# Reducing our explosion radius by a constant amount to avoid making the player
# feel cheated by an oversized radius indicator
const EXPLOSION_RADIUS_MARGIN = 0.1
const EXPLOSIVE_AREA_HEIGHT = 0.1


func simulate_explosion_from_explosive_charge_item(explosive_charge_item : ExplosiveChargeUtilityItem, pos : Vector3):
	var simulated_placed_charge : PlacedExplosiveCharge = explosive_charge_item.generate_placed_explosive_charge()
	setup_radius_from_placed_explosive_charge(simulated_placed_charge, pos)


func simulate_explosion_from_placed_explosive_charge(placed_explosive_charge : PlacedExplosiveCharge):
	setup_radius_from_placed_explosive_charge(placed_explosive_charge, placed_explosive_charge.global_position)


func setup_radius_from_placed_explosive_charge(placed_explosive_charge : PlacedExplosiveCharge, pos : Vector3):
	var explosion_radius = placed_explosive_charge.explosion.radius
	if explosion_radius:
		explosion_radius -= EXPLOSION_RADIUS_MARGIN
		
		area_of_effect_indicator.radius = explosion_radius
		area_of_effect_indicator.global_position = Vector3(pos.x, EXPLOSIVE_AREA_HEIGHT, pos.z)
		area_of_effect_indicator.generate_indicator()
		area_of_effect_indicator.show()
		
		effect_radius.scale = Vector3(explosion_radius, 1.0, explosion_radius)
		effect_radius.global_position = Vector3(pos.x, EXPLOSIVE_AREA_HEIGHT, pos.z)


func clear_all_simulated_explosions():
	effect_radius.hide()
	area_of_effect_indicator.hide()


func get_level():
	return Util.get_level(self)
