class_name RPGEventModifier extends Resource

## RPGEventModifier modifies a particular event in soem way, for example, increasing
## damage in a damage event if the player is shooting at an enemy they are particularly
## good at destroying

# The Character that is being modified by this RPGEventModifier
var character : Character


# This is an entirely abstract function, it must be overriden for every RPGEventModifier
# We decided to do this because each RPGEventModifier is going to be too bespoke to make
# a generic class for
func apply_to_event(event : RPGEvent):
	pass


func assign_character(new_character : Character):
	character = new_character
