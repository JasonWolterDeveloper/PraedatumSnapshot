extends Node

func get_viewport_center():
	var viewport_rect = get_viewport().get_visible_rect()
	var x_value = viewport_rect.position.x + viewport_rect.size.x/2
	var y_value = viewport_rect.position.y + viewport_rect.size.y/2
	return Vector2(x_value, y_value)


func get_viewport_size():
	return get_viewport().get_visible_rect().size


func get_player(game_object):
	return get_level(game_object).get_player()
	
# gets the level the given object is in
func get_level(game_object):
	if game_object == null:
		return null
	if not game_object is Level:
		return get_level(game_object.get_parent())
	else:
		return game_object
	
# Returns the first node in the parent hierarchy that is a character, or, null if there is not
# one. Useful for things like determining who is wielding a weaon for instance	
func get_character_parent(game_object):
	if game_object == null:
		return null
	if not game_object is Character:
		return get_character_parent(game_object.get_parent())
	else:
		return game_object
		
# forceAddChild removes the given child from its parent and adds it to the passed
# parent
func force_add_child(parent, child):
	if child.get_parent():
		child.get_parent().remove_child(child)
	# We need to use legible unique name here so that engine spawned objects are
	# saveable. The true bool is for the legible unique name value
	parent.add_child(child, true)
	child.owner = parent


func pick_random_array_element(array: Array):
	if array:
		# Generate a random index within the bounds of the array
		var random_index = randi() % array.size()
		
		# Access the element at the random index
		return array[random_index]
	return null


func pick_random_array_elements(array: Array, count: int) -> Array:
	# Shuffle the array to randomize it
	var shuffled_array = array.duplicate()
	shuffled_array.shuffle()

	# Return the first 'count' elements from the shuffled array
	return shuffled_array.slice(0, count)


func append_array_unique(array: Array, obj) -> void:
	if not array.has(obj):
		array.append(obj)

"""
func pick_random_array_element_excluded_indices(array_to_choose_from: Array, excluded_indexes: Array) -> int:
	var available_indexes = []
	for i in range(array_to_choose_from.size()):
		if not excluded_indexes.includes(i):
			available_indexes.append(i)
	
	if available_indexes.size() == 0:
		return null  # No available index
	
	var random_index = available_indexes[randi() % available_indexes.size()]
	return array_to_choose_from[random_index]
"""
	
# returns true if the element existed and false otherwise
func delete_object_from_array(array: Array, object_to_remove):
	# Check if the object exists in the array
	if array.has(object_to_remove):
		# Find the index of the object
		var index = array.find(object_to_remove)
		
		# Remove the object from the array
		array.remove_at(index)


func is_primitive(data):
	var data_type = typeof(data)
	return (data_type == TYPE_INT ||
		   data_type == TYPE_FLOAT ||
		   data_type == TYPE_STRING ||
		   data_type == TYPE_BOOL)
		
		
# Recursively find a child node by name
func find_node_by_name(node: Node, name_to_find: StringName) -> Node:
	# Check if the current node matches the name we are looking for
	if node.name == name_to_find:
		return node
	
	# Iterate through each child node
	for i in range(node.get_child_count()):
		var child = node.get_child(i)
		
		# Recursively search through child nodes
		var result = find_node_by_name(child, name_to_find)
		
		# If we find the node, return it
		if result:
			return result
	
	# If no matching node is found, return null or handle appropriately
	return null

func update_dictionary_from_dictionary(dictionary_a: Dictionary, dictionary_b: Dictionary) -> void:
	# Iterate through each key-value pair in dictionary_b
	for key in dictionary_b.keys():
		dictionary_a[key] = dictionary_b[key]


func get_packed_scene_from_object(my_object : Node):
	return load(my_object.scene_file_path)


# Function to perform a raycast and return the collision point or end position
func los_collision_point_raycast_full_result(pos1: Vector3, pos2: Vector3, collision_mask: int = 0x1, \
	 collision_exclusions:Array = []):
	
	var level = GameMaster.get_level()
	
	if level:
		var params := PhysicsRayQueryParameters3D.new()
		params.collision_mask = collision_mask
		params.from = Vector3(pos1.x, PhysicsConstants.LOS_HEIGHT, pos1.z)
		params.to = Vector3(pos2.x, PhysicsConstants.LOS_HEIGHT, pos2.z)
		if collision_exclusions.size() > 0:
			params.exclude = collision_exclusions
		
		var space_state : PhysicsDirectSpaceState3D = level.get_world_3d().direct_space_state
		
		var result = space_state.intersect_ray(params)
		
		if result:
			# Return the collision point
			return result
	return null


# Function to perform a raycast and return the collision point or end position
func los_collision_point_raycast(pos1: Vector3, pos2: Vector3, collision_mask: int = 0x1, \
	 collision_exclusions:Array = []) -> Vector3:
	var result = los_collision_point_raycast_full_result(pos1, pos2, collision_mask, collision_exclusions)
	if result:
		return result.position
	return pos2


## Exludes the origin node1:Node3D automatically
func check_los_to_object(node1: Node3D, node2: Node3D, collision_mask: int = 0x1) -> bool:
	var level = GameMaster.get_level()
	
	if level:
		var params := PhysicsRayQueryParameters3D.new()
		params.collision_mask = collision_mask
		params.from = Vector3(node1.global_position.x, PhysicsConstants.LOS_HEIGHT, node1.global_position.z)
		params.to = Vector3(node2.global_position.x, PhysicsConstants.LOS_HEIGHT, node2.global_position.z)
		
		params.exclude = [node1]
		
		var space_state : PhysicsDirectSpaceState3D = level.get_world_3d().direct_space_state
		
		var result : Dictionary = space_state.intersect_ray(params)
		
		if (result and result.collider == node2) or (not result.has("collider")):
			return true
	return false


func delete_all_children(node : Node):
	# Loop through all children and remove them
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


"""
	extends Node

# Given two dicts, merge them into a new dict as a shallow copy. Keeps the vars
# in the second dict by priority
func mergeDicts(x, y):
	var z = {}
	for myKey in x:
		z[myKey] = x[myKey]
	for myKey in y:
		z[myKey] = y[myKey]
	return z

func generateUID(myObject, objectList):
	var myCount = 1
	var newUID = myObject.getClassName() + str(myCount)
	while (newUID in objectList):
		myCount = myCount + 1
		newUID = myObject.getclassName() + str(myCount)
	return newUID
	
func getSceneName(scene):
	var fileName = scene.get_filename()
	fileName = FileIO.getFileName(fileName)
	fileName = FileIO.removeFileExtension(fileName)
	return fileName
	
# getCustomClassOwner recurses up the given object's owner tree until it finds
# an owner of a particular class, and then returns that. This is useful when 
# certain objects are known to be children of a particular class. For example
# all objects should have a model as one of their parents
func getCustomClassOwner(object, customClass):
	if object == null or object.is_class(customClass):
		return object
	else: return getCustomClassOwner(object.get_parent(), customClass)
	
func getActorOwner(object):
	return getCustomClassOwner(object, CustomClassConstants.ACTOR_CLASS_NAME)
	
func getGameManager(object):
	return getCustomClassOwner(object, CustomClassConstants.GAME_MANAGER_CLASS_NAME)
	
func getModel(object):
	return getCustomClassOwner(object, CustomClassConstants.WAR_SCENE_CLASS_NAME)

# returns the last element in the given list
func getLastElement(myList):
	return myList[-1]

# returns the first element in a given list
func getFirstElement(myList):
	return myList[0]
	
# For many of the pieces of data we use in our game, there is both a variable in
# code and a node in Godot's scene tree representing the piece of data. For data
# like this, when the value of it is changed, we both need to update the 
# variable in code, and update the scene tree. This function will help setters
# update the scene tree. 
func godotChildNodeSetter(parent, nodeName, newChildNode):
	var currentChildNode = parent.get_node(nodeName)
	
	# If the parent currently has a child node with the given node name, we 
	# overwrite it, so this is where we delete it
	if currentChildNode != null:
		parent.remove_child(currentChildNode)
		currentChildNode.queue_free()
		
	# Setting the name of the new child node to the node name it is replacing in
	# the parent, just in case
	newChildNode.name = nodeName
	
	# Adding the child node to the parent's scene tree
	forceAddChild(parent, newChildNode)
	
func getRectCenter(rectPos, rectSize):
	return Vector2(rectPos.x + rectSize.x/2, rectPos.y + rectSize.y/2)
	
func godotPathJoin(string1, string2):
	return string1 + "/" + string2
	
func getViewportSize():
	return get_viewport().size
	
func getViewportCenter():
	var xpos = getViewportSize().x/2
	var ypos = getViewportSize().y/2
	
	return Vector2(xpos, ypos)
"""

	
