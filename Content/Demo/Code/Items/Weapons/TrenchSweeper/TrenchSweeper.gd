class_name TrenchSweeper extends GunInternalMagazine

## Alt-fire triggers an instant burst with increased damage and recoil
## TrenchSweeperPellet's instance vars are prioritized over TrenchSweeperBuckshot's

enum side {RIGHT, LEFT, BOTH}

@export var alt_additional_pellets:int = 1 ## Per shot in the alt fire
@export var alt_fire_shots:int = 2

@export var both_barrels_screen_shake : float = 0.25
@export var both_barrels_screen_shake_recovery : float = 0.14
@export var both_barrels_screen_flash : float = 0.6
@export var both_barrels_screen_recovery : float = 0.2

var previous_ammo_level:ammo_level # For playing the correct pump sound
var ejection_side:side # For alternating between ejection ports

@onready var original_recoil:float = recoil_per_shot
@onready var sound_master:SoundMaster = $SoundMaster
@onready var pump_timer:Timer = $PumpTimer


func _ready():
	super()
	reload_master.mag_inserted.connect(sound_master.play.bind("ShellInsert"))
	reload_master.mag_inserted_perfect.connect(sound_master.play.bind("ShellInsert"))
	fired.connect(pump_timer.start.unbind(1)) # Do not override wait_time with ammo_level
	fired.connect(play_fire_sound)
	pump_timer.timeout.connect(pump)


## @Override
func fire():
	previous_ammo_level = get_current_ammo_level()
	match ejection_side:
		side.RIGHT: ejection_side = side.LEFT
		_: ejection_side = side.RIGHT
	super()


#@ @Override
func pull_alt_fire():
	super()
	both_barrels()


func both_barrels():
	if current_ammo_count >= alt_fire_shots:
		ejection_side = side.BOTH
		previous_ammo_level = get_current_ammo_level()
		sound_master.play("SuperFire")
		pump_timer.start()
		
		has_shot_since_last_trigger_pull = true
		time_since_last_shot = 0.0
		
		handle_ammo_consumption(2)
		
		# Generate the data such as collisions and bullet endpoint for the actual 
		# shot we just took
		var trajectory = get_aiming_master().generate_shot_trajectory_with_spread(calculate_spread())
		handle_recoil(recoil_per_shot * alt_fire_shots)
		
		# Both shots use the exact same trajectory
		generate_and_fire_bullet(trajectory)
		generate_and_fire_bullet(trajectory)
		generate_firing_noise()
		
		ScreenShakeMaster.request_screen_shake(both_barrels_screen_shake, false, )
		VignetteMaster.request_gunshot_vignette(both_barrels_screen_flash, both_barrels_screen_recovery)
	else:
		sound_master.play("DryFire")


func generate_bullet() -> Bullet:
	var bullet = super()
	
	if alt_fire_down:
		bullet.number_of_pellets += alt_additional_pellets
	
	return bullet


func play_fire_sound(current_ammo_level:ammo_level) -> void:
	match current_ammo_level:
		ammo_level.HIGH: sound_master.play("FireHigh")
		ammo_level.LOW: sound_master.play("FireLow")
		ammo_level.CRITICAL: sound_master.play("FireCritical")
		_: sound_master.play("DryFire")


## Play the pump sound effect and eject shells
func pump() -> void:
	# For the ejection ports:
	const RIGHT_BITMASK = 1
	const LEFT_BITMASK = 2
	var ejection_ports := get_ejection_ports()
	
	if previous_ammo_level != ammo_level.DRY:
		match previous_ammo_level: # Play sound effect
			ammo_level.HIGH: 
				sound_master.play("PumpHigh")
			ammo_level.LOW: 
				sound_master.play("PumpLow")
			ammo_level.CRITICAL: 
				sound_master.play("PumpCritical")
		previous_ammo_level = ammo_level.DRY

		if ejection_ports.size() > 1: # TODO - Switched this to 1 to cover scenarios where you swap weapons while pumping, but should probably do more
			if (ejection_side + 1) & RIGHT_BITMASK:
				ejection_ports[0].spawn_casing()
			if (ejection_side + 1) & LEFT_BITMASK:
				ejection_ports[1].spawn_casing()
