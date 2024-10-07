extends RPGAbility



# ---------- Active Ability Functions---------- #


# Effect function for when the ability key is pressed. Should be overridden
func ability_pressed_effect():
	OnScreenMessageMaster.display_message("Pressed Ability 2")


# Effect function for when the ability key is released. Should be overridden
func ability_released_effect():
	OnScreenMessageMaster.display_message("Released Ability 2")
