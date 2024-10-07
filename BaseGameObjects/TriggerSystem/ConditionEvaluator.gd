## ConditionEvaluator is a resource type that is meant to help various other nodes in the game
## determine if certain conditions are valid before doing certain things. For example, a trigger to display a message
## on screen might only fire if the player has a certain quest item in their inventory. An enemy might only spawn if the Player
## has a quest mission to kill that enemy. And a conversation option might only be available if a certain quest is completed
## Instead of trying to manually create different triggers, spawners, conversation dialog options, etc. for each of these scenarios
## we give arrays of ConditionEvaluator resources to each of them, and then they run through all of the conditions, checking evaluate
## for each one before doing whatever it is they need to do
class_name ConditionEvaluator extends Resource

@export var inverted : bool = false

# Override the evaluate method
func evaluate() -> bool:
	# Default implementation returns true
	return true


func evaluate_true() -> bool:
	return not inverted
	

func evaluate_false() -> bool:
	return inverted
