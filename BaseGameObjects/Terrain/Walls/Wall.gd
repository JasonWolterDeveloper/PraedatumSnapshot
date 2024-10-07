class_name Wall extends StaticBody3D

@export var wall_thickness : float = 0.2
@export var wall_height : float = 4.0

@onready var collision_shape : CollisionShape3D = $CollisionShape3D


func _ready():
	size_collision_shape()
	place_collision_shape()
	reset_scale()


func place_collision_shape():
	collision_shape.position.y =  wall_height/2.0


func size_collision_shape():
	collision_shape.shape.size.z = wall_thickness
	collision_shape.shape.size.y = wall_height
	
	# We want our collision shape's x to match our x scale, as, our x scale
	# is how we size the wall
	collision_shape.shape.size.x = scale.x


## generate_wall_of_length - MUST BE CALLED BEFORE Wall is added to SCENE TREE
## C
func generate_wall_of_length(length):
	scale.x = length


# we reset our scale by applying our scale to all of our children except our
# collision shape, then setting our scale to 1. This way we will avoid impacting
# our collision shape
func reset_scale():
	var my_scale = Vector3(scale)
	scale = Vector3(1, 1, 1)
	for my_child in get_children():
		if my_child != collision_shape:
			my_child.scale = my_scale
