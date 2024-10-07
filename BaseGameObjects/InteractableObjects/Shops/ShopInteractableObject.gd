## Shop Interactable Object is an interactable object that opens a shop menu for the player to
## be able to use to buy and sell to a particular store that is a child of this object
class_name ShopInteractableObject extends InteractableObject

@export var shop : Shop


func activate(activator : Character):
	super(activator)
	if shop:
		shop.open_shop_menu()
