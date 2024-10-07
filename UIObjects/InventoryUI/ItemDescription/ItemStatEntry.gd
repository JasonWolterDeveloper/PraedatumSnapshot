## ItemStatEntry is a resource intended to be used alongside items to give various important stats
## about the item in the UI along with instructions for nicely formatting the Stat Entry in the UI, such as 
## the colour of the value. Each item should have an array of thse entries that the ItemDescriptionDetailMenu
## interates through
class_name ItemStatEntry extends Resource

@export var stat_title : String = ""
@export var stat_value : String = ""
@export var stat_value_colour : Color = Color.WHITE
