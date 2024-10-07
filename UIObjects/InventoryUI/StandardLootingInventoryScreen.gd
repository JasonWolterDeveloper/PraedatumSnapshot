extends StandardInventoryScreen

class_name StandardLootingInventoryScreen

onready var lootingObject = null
onready var lootInventoryContainer = $LootInventory


func setupLootInventoryContainer(lootingInventory):
	getLootInventoryContainer().setItemHolder(lootingInventory)
	
func setupFromActorAndLootObject(myActor, myLootObject):
	setupFromActor(myActor)
	setLootingObject(myLootObject)
	
	setupLootInventoryContainer(getLootingObject().getInventory())

##### Getters and Setters #####


func getLootingObject():
	return lootingObject

func setLootingObject(val):
	lootingObject = val

func getLootInventoryContainer():
	return lootInventoryContainer

func setLootInventoryContainer(val):
	lootInventoryContainer = val

