class_name PlacedExplosiveCharge extends Node3D

@export var explosion : Explosion
@export var graphics : Node3D

var door : Door = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	
func place_on_door(new_door: Door, side):
	door = new_door
	Util.force_add_child(new_door, self)
	if side == new_door.DOOR_INNER_SIDE:
		position = door.inner_bomb_position.position
		# rotation = door.right_side_bomb_rotation
	else:
		position = door.outer_bomb_position.position
		# rotation = door.left_side_bomb_rotation


func place_on_wall(pos : Vector3, character: Character):
	Util.force_add_child(character.level, self)
	global_position = pos


func place(character : Character):
	place_on_ground(character.global_position, character.get_level())
	
	
func place_on_ground(pos : Vector3, level: Level):
	Util.force_add_child(level, self)
	global_position = pos


func face_toward(pos : Vector3):
	look_at(pos)
	
	
func on_explosion_finished():
	queue_free()


func detonate():
	if door:
		door.destroy_door()
		
	if graphics:
		graphics.hide()
		
	if explosion:
		explosion.connect("explosion_finished", on_explosion_finished)
		explosion.explode()
	
	# new_explosion.global_rotation = global_rotation
