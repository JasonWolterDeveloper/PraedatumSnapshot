class_name BaseUpgradeRecipe extends CraftingRecipe


## The Level that the Base Upgrade will be after this upgrade is
## received
@export var upgrade_for_level : int = 1


func base_at_correct_level():
	# We want to check that the base facility is current 1 below our current level
	return base_facility.current_upgrade_level == (upgrade_for_level - 1)


func check_can_upgrade():
	return base_at_correct_level() and check_has_enough_item_quantity() and check_has_enough_base_power()


func upgrade():
	if check_can_upgrade():
		pay_crafting_cost()
		pay_power_cost()
		base_facility.upgrade(upgrade_for_level)
