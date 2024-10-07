class_name AIProperties extends Resource

## For customizing the behaviour of an FSM; mostly for re-using the same FSM for different enemies
## without needing to create a bespoke variant for each enemy. Applies to ALL relevant States/Links 
## in an FSM. If you only want a property to apply to SOME States/Links of a particular type, create 
## an exported var in the Link instead.  

@export var state_properties:Dictionary = \
{
}
@export var link_properties:Dictionary = \
{
}
