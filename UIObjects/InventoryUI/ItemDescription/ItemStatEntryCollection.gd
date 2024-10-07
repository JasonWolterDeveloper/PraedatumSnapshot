## ItemStatEntryCollection is a Resource the combines a lot of stat entries together into a big
## grouping. This makes it easier to copy groups of stats from one item to another
class_name ItemStatEntryCollection extends Resource

@export var stat_entry_array : Array[ItemStatEntry] = []
