class_name LootDrop extends RigidBody3D

@export var ground_item : GroundItem
var time_to_live : float = 10.0
var time_alive = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_alive += delta
	if time_alive > time_to_live:
		self_delete()


func self_delete():
	if is_instance_valid(ground_item):
		var current_position = ground_item.global_position
		Util.force_add_child(GameMaster.get_level(), ground_item)
		ground_item.global_position = current_position
	queue_free()


func setup_loot_item(loot_item : Item):
	ground_item.setup_from_item(loot_item)


# --------- Vector Generation ---------- #


func launch_in_random_direction():
	linear_velocity = generate_random_vector()

# Function to generate a random Vector3
func generate_random_vector(min_magnitude: float = 2.0, max_magnitude: float = 4.0, y_value: float = 5.0) -> Vector3:
	# Generate a random direction
	var random_direction = Vector3(
		randf_range(-1.0, 1.0),
		0,  # We will set Y later
		randf_range(-1.0, 1.0)
	).normalized()

	# Generate a random magnitude
	var random_magnitude = randf_range(min_magnitude, max_magnitude)
		
	# Scale the direction by the random magnitude
	var vector = random_direction*random_magnitude

	# Set the Y component
	vector.y = y_value

	return vector


# Function to generate a vector towards a target point
func generate_vector_towards_point(from: Vector3, to: Vector3, min_magnitude: float = 3.0, max_magnitude: float = 6.0) -> Vector3:
	# Calculate the direction vector from 'from' to 'to'
	var direction = (to - from).normalized()
	
	# Generate a random magnitude
	var random_magnitude = randf_range(min_magnitude, max_magnitude)
	
	# Set the Y component to 5
	direction.y = 5
	
	# Scale the direction vector by the random magnitude
	return direction.normalized() * random_magnitude


func assign_camera(camera : Camera3D):
	ground_item.assign_camera(camera)
