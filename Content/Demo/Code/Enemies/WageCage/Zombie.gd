class_name Zombie extends Enemy

@export var slow_status_effect_scene : PackedScene
@export var dot_status_effect_scene : PackedScene
@onready var electric_shock_model : ElectricShockModel = $LookStuff/ElectrickShockModel
@onready var electric_shock_model_2 : ElectricShockModel = $LookStuff/ElectrickShockModel2

@export var wage_cage_gibs_scene : PackedScene

@onready var player_detected_bark : BarkType = $WageCagePlayerDetectedBarkType


# Tells the AimingMaster we're a melee enemy
func is_unarmed():
	return true


func can_attack_target(target_character : Character):
	if not stunned:
		for body in melee_area.get_overlapping_bodies():
			if body == target_character or body == target_character.projectile_hitbox:
				return check_los_to_character()


func display_attack_visuals(target_character : Character):
	electric_shock_model.play_eletric_shock_animation_toward_point(target_character.global_position)
	electric_shock_model_2.play_eletric_shock_animation_toward_point(target_character.global_position)


func attack_target(target_character : Character):
	if target_character is Player and player_damaged_aesthetic_effect:
		player_damaged_aesthetic_effect.play_damage_effect()
	
	#Applying DOT effect to target character
	var dot_effect = dot_status_effect_scene.instantiate()
	target_character.rpg_mechanics_master.add_status_effect(dot_effect)
	
	# Applying Slow Effect to target character
	#var current_slow_effect : SlowStatusEffect = target_character.rpg_mechanics_master.find_status_effect_of_type(SlowStatusEffect)
	#if current_slow_effect:
		#current_slow_effect.current_duration = 0.0
	#else:
	var slow_effect = slow_status_effect_scene.instantiate()
	target_character.rpg_mechanics_master.add_or_refresh_status_effect(slow_effect)
	
	display_attack_visuals(target_character)


func on_death():
	var wage_cage_gibs = wage_cage_gibs_scene.instantiate()
	Util.force_add_child(Util.get_level(self), wage_cage_gibs)
	wage_cage_gibs.global_position = global_position
	wage_cage_gibs.rotation = $LookStuff.rotation
	wage_cage_gibs.apply_physics_gibs()
	
	super()


func _process(delta):
	super(delta)
	if Input.is_action_just_pressed("debug_4"):
		var stun_scene = load("res://BaseGameObjects/RPGMechanics/StatusEffects/StunnedStatusEffect.tscn")
		var stun = stun_scene.instantiate()
		rpg_mechanics_master.add_status_effect(stun)
