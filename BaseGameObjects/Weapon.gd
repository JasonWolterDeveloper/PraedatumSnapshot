class_name Weapon extends Item

#@export var damage = 10.0 # Guns use Bullet.damage instead
@export var use_custom_crosshair:bool = false

@export var weapon_pose : String = ""
@export var weapon_model_scene : PackedScene

# Even though only guns have triggers, we use "trigger_down" to deal with any
# situation where holding down the weapon button causes different behaviour
# than simply pressing it, such as charging up the swing of a melee weapon or
# cooking a grenade
var trigger_down := false
var alt_fire_down := false


func pull_trigger():
	trigger_down = true


func release_trigger():
	trigger_down = false


func pull_alt_fire():
	alt_fire_down = true


func release_alt_fire():
	alt_fire_down = false


func is_equipped():
	return not get_weapon_wielder() == null and get_weapon_wielder().get_equipped_item() == self


func get_weapon_wielder():
	return Util.get_character_parent(self)


func get_level():
	return Util.get_level(self)


## Virtual function
func handle_equipped(delta:float) -> void:
	pass
