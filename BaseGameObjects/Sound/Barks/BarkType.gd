class_name BarkType extends AudioStreamPlayer3D

@export var bark_type_string : String
var barks_array : Array[Bark] = []


func _ready():
	populate_barks_array()


func populate_barks_array():
	for my_child in get_children():
		if my_child is Bark:
			barks_array.append(my_child)


func check_can_bark():
	return BarkMaster.can_bark_type_bark(bark_type_string)


func select_random_bark_from_bark_master():
	return BarkMaster.select_random_bark_no_repeats(bark_type_string, barks_array)


#Notify the bark master that this type of bark just emitted the bark at the
#given index in the bark array
func notify_bark_master_of_bark(index : int):
	BarkMaster.notify_bark_occured(bark_type_string, index, barks_array[index])


# func conduct_bark(index : int):

# Emits the bark. We don't call random bark directly just in case we don't want
# the bark to be random for a particular bark
func emit_bark():
	if check_can_bark():
		play_random_bark()


func play_random_bark():
	var bark_index = select_random_bark_from_bark_master()
	play_bark_sound(bark_index)
	
	
func play_bark_sound(index : int):
	var bark : Bark = barks_array[index]
	stream = bark.audio
	notify_bark_master_of_bark(index)
	play()
