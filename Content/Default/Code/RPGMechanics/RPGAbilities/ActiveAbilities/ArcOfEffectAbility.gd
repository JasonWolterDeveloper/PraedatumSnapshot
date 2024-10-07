class_name ArcOfEffectAbility extends AreaOfEffectAbility


# Overriding spawn area of effect to also give it a direction. Note that even though we allow you to check
# the exported aim point box, practically speaking the arc of effect ability only permits spawning at the player's
# position
func spawn_area_of_effect() -> AreaOfEffect:
	var arc_of_effect = super()
	arc_of_effect.set_direction(player.aiming_master.look_direction_vector())
	return arc_of_effect


func on_deselected():
	super()
	# Need to stop casting if we swap to another ability to avoid disasterous results
	casting = false
