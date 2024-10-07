class_name TurretEnemyGibs extends EnemyGibs


func set_rotation_for_relevant_stuff(angle):
	$TurretGimbal.rotation = angle
	$TurretGun.rotation = angle
