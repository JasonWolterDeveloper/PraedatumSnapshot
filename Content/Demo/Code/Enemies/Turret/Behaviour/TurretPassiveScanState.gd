class_name TurretPassiveScanState extends State

## Turret just sorta lookin around

func on_entry(phys_delta) -> bool:
	super(phys_delta)
	my_character.deactivate_turret()
	my_character.aiming_master.aim_point = Vector3(0, 0, 1)
	return true # One-shot routine
