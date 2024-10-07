class_name BaseFacilityPowerPip extends BoxContainer


func set_empty():
	$FullPip.hide()
	$EmptyPip.show()


func set_full():
	$FullPip.show()
	$EmptyPip.hide()
