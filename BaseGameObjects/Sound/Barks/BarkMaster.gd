# BarkMaster is a global singleton that helps to manage barks being made
# by primarily enemy NPCs. The point of this node is so that multiple NPC barks don't overlap
# and so that the same barks don't get said over and over again. It is global and will be
# accessed by individual enemies when they want to make a bark
extends Node

const BASE_BARK_WAIT_TIME = 0.2
var time_to_wait_to_next_bark = 0.0

# The following dictionary is used to make sure we don't play the exact same randomly selected bark
# twice in a row. Each situation we need to generate barks for, for example, the Wage Cage detecting 
# the player, will have a bark_type string associated with it, as well as an array of different barks that
# could be played for that bark type. When a bark is made for that bark type, we will record what index
# the bark was in that array so that it is not repeated
var most_recent_bark_index_by_bark_type : Dictionary = {}


func _process(delta):
	if time_to_wait_to_next_bark > 0:
		time_to_wait_to_next_bark -= delta


func can_bark():
	return time_to_wait_to_next_bark <= 0


func can_bark_type_bark(bark_type_string : String) -> bool:
	return can_bark()


func select_random_bark_no_repeats(bark_type_string : String, bark_array : Array[Bark]):
	var exclude_index = -1
	if bark_type_string in most_recent_bark_index_by_bark_type:
		exclude_index = most_recent_bark_index_by_bark_type[bark_type_string]
	var choice_array : Array[Bark] = []
	for i in range(len(bark_array)):
		if i != exclude_index:
			choice_array.append(bark_array[i])
	return bark_array.find(bark_choice(choice_array))
		

func bark_choice(bark_array: Array[Bark]):
	var sum:float = 0.0
	for bark : Bark in bark_array:
		sum += bark.weight
	
	var normalizedWeights = []

	for bark : Bark in bark_array:
		normalizedWeights.append(bark.weight / sum)

	var rnd = randf()

	var i = 0
	var summer:float = 0.0

	for val in normalizedWeights:
		summer += val
		if summer >= rnd:
			return bark_array[i]
		i += 1


func notify_bark_occured(bark_type : String, bark_index : int, bark : Bark):
	most_recent_bark_index_by_bark_type[bark_type] = bark_index
	setup_time_to_wait_to_next_bark(bark)


func setup_time_to_wait_to_next_bark(bark : Bark):
	time_to_wait_to_next_bark = BASE_BARK_WAIT_TIME + bark.audio.get_length()
