class_name Barracuda extends Gun

@onready var sound_master:SoundMaster = $SoundMaster



func _ready():
	super()
	reload_master.mag_ejected.connect(sound_master.play.bind("MagEject"))
	reload_master.mag_inserted.connect(sound_master.play.bind("MagInsert"))
	reload_master.mag_inserted_perfect.connect(sound_master.play.bind("MagInsertPerfect"))
	fired.connect(play_fire_sound)


func fire():
	super()
	eject_round()


func play_fire_sound(current_ammo_level:ammo_level) -> void:
	match current_ammo_level:
		ammo_level.HIGH: sound_master.play("FireHigh")
		ammo_level.LOW: sound_master.play("FireLow")
		ammo_level.CRITICAL: sound_master.play("FireCritical")
		_: sound_master.play("DryFire")
