class_name GunInternalMagazine extends Gun


""" - Now that all guns have internal magazines this is all pretty much usesless
@export var internal_magazine_capacity = 5

# The Intenal Magazine is an Array of Bullet Objects. The bullets don't actually
# get added to the scene until they are fired
var internal_magazine : Array[Bullet] = []


# Inserts a bullet from a magazine to our internal magazine
func insert_bullet(origin_magazine : Magazine):
	var new_bullet = origin_magazine.generate_bullet()
	internal_magazine.append(new_bullet)
	origin_magazine.current_quantity -= 1

# We need a distinct function for firing bullets as the behaviour is very different between
# Guns with internal magazines and regular guns
func fire_bullet(trajectory):
	if internal_magazine:
		var new_bullet = internal_magazine.pop_front()
		get_level().add_child(new_bullet)
		new_bullet.fire_bullet(get_weapon_wielder().position, trajectory, self, get_weapon_wielder())
"""
