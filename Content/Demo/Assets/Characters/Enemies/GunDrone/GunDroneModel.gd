extends Node3D

@onready var animation_player := $AnimationPlayer
@onready var gunshot_stream := $GunshotStream



# ---------- Weapon Aesthetics Functions -----------#


func play_weapon_aesthetics():
	play_weapon_fire_animation()
	play_weapon_fire_audio()


func play_weapon_fire_animation():
	animation_player.play("WeaponFire")


func play_weapon_fire_audio():
	gunshot_stream.play()
	
