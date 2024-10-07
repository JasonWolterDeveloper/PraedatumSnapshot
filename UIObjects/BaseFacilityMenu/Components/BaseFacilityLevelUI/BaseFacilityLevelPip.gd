class_name BaseFacilityLevelPip extends BoxContainer


func set_full():
	$Empty.hide()
	$Filled.show()


func set_empty():
	$Empty.show()
	$Filled.hide()
