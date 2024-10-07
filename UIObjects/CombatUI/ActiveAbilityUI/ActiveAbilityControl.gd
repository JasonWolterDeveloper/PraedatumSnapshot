class_name ActiveAbilityControl extends Control


# ----- Control References ----- #
var ability_use_key_texture : TextureRect
var ability_name_label : Label
var cool_down_tracker : ProgressBar
var cool_down_label : Label

# ----- Model References ----- #
var ability_to_track : RPGAbility



# ---------- Ready and Assignment Functions ---------- #


func _ready():
	ability_use_key_texture =  Util.find_node_by_name(self, "AbilityUseKeyTexture")
	ability_name_label =  Util.find_node_by_name(self, "AbilityNameLabel")
	cool_down_tracker =  Util.find_node_by_name(self, "CooldownTracker")
	cool_down_label = Util.find_node_by_name(self, "CooldownLabel")


func assign_ability(new_ability : RPGAbility):
	ability_to_track = new_ability
	update()



# ---------- Update Functions ---------- #


func update():
	if ability_to_track != null:
		ability_use_key_texture.show()
		update_ability_name()
		update_cool_down()
	else:
		update_for_no_ability()


func update_for_no_ability():
	ability_name_label.text = ""
	cool_down_tracker.value = 0.0
	cool_down_label.hide()
	ability_use_key_texture.hide()


func update_ability_name():
	ability_name_label.text = ability_to_track.display_name


func update_cool_down():
	if ability_to_track.is_in_cooldown:
		cool_down_label.show()
		cool_down_tracker.value = ability_to_track.calculate_cooldown_percentage()
	else:
		cool_down_tracker.value = 100.0
		cool_down_label.hide()


func _process(delta: float) -> void:
	if ability_to_track:
		update()
