extends InventoryUIManager

class_name StandardInventoryScreen

onready var mainInventoryContainer = $MainInventory

onready var primaryWeaponSlot = $PrimaryWeaponSlot
onready var secondaryWeaponSlot = $SecondaryWeaponSlot

var inventoryActor = null

func setupMainInventoryContainer(mainInventory):
	getMainInventoryContainer().setItemHolder(mainInventory)
	
func setupPrimaryWeaponSlot(weaponSlot):
	getPrimaryWeaponSlot().setItemHolder(weaponSlot)
	
func setupSecondaryWeaponSlot(weaponSlot):
	getSecondaryWeaponSlot().setItemHolder(weaponSlot)
	
func setupFromActor(myActor):
	setInventoryActor(myActor)
	
	setupMainInventoryContainer(getInventoryActor().getInventory())
	
	setupPrimaryWeaponSlot(getInventoryActor().getPrimaryWeaponSlot())
	setupSecondaryWeaponSlot(getInventoryActor().getSecondaryWeaponSlot())


##### Getters and Setters #####


func getMainInventoryContainer():
	return mainInventoryContainer

func setMainInventoryContainer(val):
	mainInventoryContainer = val

func getPrimaryWeaponSlot():
	return primaryWeaponSlot

func setPrimaryWeaponSlot(val):
	primaryWeaponSlot = val

func getSecondaryWeaponSlot():
	return secondaryWeaponSlot

func setSecondaryWeaponSlot(val):
	secondaryWeaponSlot = val

func getInventoryActor():
	return inventoryActor

func setInventoryActor(val):
	inventoryActor = val

