class_name hitbox extends CharacterBody3D

# The ProjectileHitBox exists to let projectile based weapons have different hitboxes than the actual
# physical collisions that characters use to interact with the terrain. This lets character sprites overlap
# with terrain slightly to allow easier, more realistic movement, while also ensuring that the player
# always hits with hit scan weapons when they are shot towards an enemy's sprite

@export var damage_multiplier : float = 1


func _ready():
	set_collision_layer_value(3, true)


func deal_damage_to_character(damage, origin_character : Character = null, weapon : Weapon = null, bullet : Bullet = null):
	var final_damage = damage * damage_multiplier
	RPGEventMaster.invoke_damage_event(final_damage, get_character(), origin_character, weapon, bullet)


func get_character():
	return Util.get_character_parent(self)
