class_name OlReliableWeaponModel extends WeaponModel

@onready var weapon_light_one = $WeaponLightOne/ActualLightOne
@onready var weapon_light_two = $WeaponLightTwo/ActualLightTwo
@onready var weapon_light_three = $WeaponLightThree/ActualLightThree


func _process(delta):
	if is_instance_valid(weapon) and weapon is OlReliable:
		match weapon.calculate_current_charge_level():
			0:
				weapon_light_one.hide()
				weapon_light_two.hide()
				weapon_light_three.hide()
			1:
				weapon_light_one.show()
				weapon_light_two.hide()
				weapon_light_three.hide()
			2:
				weapon_light_one.show()
				weapon_light_two.show()
				weapon_light_three.hide()
			3:
				weapon_light_one.show()
				weapon_light_two.show()
				weapon_light_three.show()
			_:
				weapon_light_one.hide()
				weapon_light_two.hide()
				weapon_light_three.hide()
