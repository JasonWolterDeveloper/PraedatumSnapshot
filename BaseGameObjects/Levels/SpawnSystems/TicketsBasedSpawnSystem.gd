## Ticket as in Battlefield Based Spawn System. NOTE BENE - This system works not by
## Actually spawning objects but by wrapping through their children and selecting a random
## amount and deleting the ones that are not selected. We do it this way to make it simpler
## To just place and position units in the editor and randomly select which actually spawn
## Rather than using SpawnPoints
class_name TicketBasedSpawnSystem extends Node3D


## Max_total_spawn_tickets is the maximum randomized amount of spawn tickets
## This spawner will receive. If min_total_spawn_tickets is set to -1 then this
## is the only value that will be used, I.E. the ticket number will not be random
@export var max_total_spawn_tickets : int = 5
## Min_total_spawn_tickets if you use -1 for this value it means you aren't
## Using a randomized spawn ticket amount and only max_total_spawn_tickets will
## be used
@export var min_total_spawn_tickets : int = -1

@export var spawn_ticket_cost : int = 1

## spawn_conditions are the conditions we check before we spawn everything in this
## spawner. If this is empty or null, we will always spawn 
@export var spawn_conditions : Array[ConditionEvaluator] = []


func _ready():
	# We can handle the spawns in the ready function because this has to do with
	# our children, and all of our children are guaranteed to be ready by the time
	# we do this
	attempt_spawn()


func using_randomized_spawn_tickets():
	return min_total_spawn_tickets != -1


func check_is_ticket_spawnable_object(object):
	return object.has_method("get_spawn_ticket_cost")


func generate_potential_spawn_list():
	var potential_spawn_list = []
	for my_child in get_children():
		if check_is_ticket_spawnable_object(my_child):
			potential_spawn_list.append(my_child)
	return potential_spawn_list
	

## Remove any objects from the potential spawn list that can't possibly be spawned
## With the amount of tickets we have list. This WILL modify the passed in array
func prune_potential_spawn_list_for_expensive_objects(potential_spawn_list : Array, remaining_tickets : int):
	var prune_list = []
	# Detecting objects to prune and adding them to the lest
	for my_object in potential_spawn_list:
		# Not sure how this would get here, but we want to prune not ticket spawnable objects from the list
		if not check_is_ticket_spawnable_object(my_object):
			prune_list.append(my_object)
		elif my_object.get_spawn_ticket_cost() > remaining_tickets:
			prune_list.append(my_object)
	
	# Actually modifying the list
	for my_object in prune_list:
		Util.delete_object_from_array(potential_spawn_list, my_object)


func handle_spawns_recursive(potential_spawn_list : Array, spawn_list : Array, remaining_tickets : int):
	# First we make sure we don't have any items we can't afford to spawn in the list
	prune_potential_spawn_list_for_expensive_objects(potential_spawn_list, remaining_tickets)
	
	# If we're out of tickets, or potential objects to spawn, we simply return here. Otherwise, we
	# recurse again
	if potential_spawn_list.is_empty() or remaining_tickets <= 0:
		return
	
	# Now we select a random object from the pruned list, append it to our spawn list, subtract
	# its ticket cost, and then take it out of the potential spawn array
	var randomly_selected_spawn_object = Util.pick_random_array_element(potential_spawn_list)
	spawn_list.append(randomly_selected_spawn_object)
	remaining_tickets -= randomly_selected_spawn_object.get_spawn_ticket_cost()
	Util.delete_object_from_array(potential_spawn_list, randomly_selected_spawn_object)
	
	# If we're out of tickets, or potential objects to spawn, we simply return here. Otherwise, we
	# recurse again
	if potential_spawn_list.is_empty() or remaining_tickets <= 0:
		return
	else:
		handle_spawns_recursive(potential_spawn_list, spawn_list, remaining_tickets)


func delete_objects_not_in_spawn_list(spawn_list : Array):
	var list_of_objects_to_delete = []
	
	# The list of objects that we could potentially delete is the same as the list
	# we could potentially spawn. This is because this system works by selecting the
	# objects we want from a list of already exiting objects and deleting the ones we don't
	# like
	var potential_delete_list = generate_potential_spawn_list()
	
	# Populating the delete list
	for my_object in potential_delete_list:
		if not my_object in spawn_list:
			list_of_objects_to_delete.append(my_object)
			
	# Actually deleting the objects
	for my_object in list_of_objects_to_delete:
		remove_child(my_object)
		my_object.queue_free()


func attempt_spawn():
	if check_spawn_conditions():
		handle_spawns()
	else:
		# if we don't pass spawn conditions, we delete all spawnable objects under us
		delete_objects_not_in_spawn_list([])


## Handle "spawning" our children. The way this will be done, is all of our children
## Will initially be spawned, and we will create a list of children we are keeping,
## and any children not in that list will be deleted
func handle_spawns():
	# We start with a list of all the objects that could potentially be spawned, with our actual
	# spawn list being empty. We also set our base remaining tickets to our total tickets
	var potential_spawn_list = generate_potential_spawn_list()
	var spawn_list = []
	var remaining_tickets = max_total_spawn_tickets

	if using_randomized_spawn_tickets():
		remaining_tickets = randi_range(min_total_spawn_tickets, max_total_spawn_tickets)
	
	# We now use the handle_spawns_recursive function to actually populate the spawn_list
	handle_spawns_recursive(potential_spawn_list, spawn_list, remaining_tickets)
	
	delete_objects_not_in_spawn_list(spawn_list)

# Checks to see if we should spawn at all based on our conditions
func check_spawn_conditions():
	for condition_evaluator : ConditionEvaluator in spawn_conditions:
		if not condition_evaluator.evaluate():
			return false
	return true

func get_spawn_ticket_cost():
	return spawn_ticket_cost
