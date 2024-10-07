class_name RPGTags extends Resource

@export var tags: Array[String] = []


func has_tag(tag: String) -> bool:
	return tag in tags
