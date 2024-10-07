class_name TheBackup extends Gun

@export var shots_per_burst_semi : int = 1
@export var shots_per_burst_burst : int = 3

@export var base_spread_semi := 0.05
@export var base_spread_burst := 0.15

@export var time_between_shots_semi := 0.1
@export var time_between_shots_burst := 0.4

var is_in_burst_mode = false

@onready var sound_master:SoundMaster = $SoundMaster

func _ready():
	super()
	reload_master.mag_ejected.connect(sound_master.play.bind("MagEject"))
	reload_master.mag_inserted.connect(sound_master.play.bind("MagInsert"))
	reload_master.mag_inserted_perfect.connect(sound_master.play.bind("MagInsertPerfect"))
	fired.connect(play_fire_sound)
	alt_fired.connect(sound_master.play.bind("DryFire"))


func fire():
	super()
	eject_round()


func pull_alt_fire():
	super()
	toggle_fire_mode()
	sound_master.play("SelectFire")


func toggle_fire_mode():
	if is_in_burst_mode:
		select_semi_auto()
	else:
		select_burst_fire()


func select_semi_auto():
	OnScreenMessageMaster.display_message("Semi Auto Selected")
	shots_per_burst = shots_per_burst_semi
	base_spread = base_spread_semi
	time_between_shots = time_between_shots_semi
	is_in_burst_mode = false


func select_burst_fire():
	OnScreenMessageMaster.display_message("Burst Fire Selected")
	shots_per_burst = shots_per_burst_burst
	base_spread = base_spread_burst
	time_between_shots = time_between_shots_burst
	is_in_burst_mode = true


func play_fire_sound(current_ammo_level:ammo_level) -> void:
	match current_ammo_level:
		ammo_level.HIGH: sound_master.play("FireHigh")
		ammo_level.LOW: sound_master.play("FireLow")
		ammo_level.CRITICAL: sound_master.play("FireCritical")
		_: sound_master.play("DryFire")
