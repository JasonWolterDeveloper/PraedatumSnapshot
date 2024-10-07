extends SpawnStringMapper

func  _ready():
	spawn_string_to_scene_dictionary["basic_medical_loot"] = preload("res://Content/Demo/Code/InteractableObjects/BasicMedicalLootObject.tscn")
