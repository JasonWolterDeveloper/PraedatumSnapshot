class_name NLIDoor extends Door

@onready var door_lock_mesh_1 = $LeftDoor/Lock
@onready var door_lock_mesh_2 = $LeftDoor/Lock_001

@export var locked_door_material : StandardMaterial3D


func _ready():
	super()
	update_locked_unlocked_door_materials()


func update_locked_unlocked_door_materials():
	if locked or force_locked_override:
		door_lock_mesh_1.set_surface_override_material(1, locked_door_material)
		door_lock_mesh_2.set_surface_override_material(1, locked_door_material)
	else:
		door_lock_mesh_1.set_surface_override_material(1, null)
		door_lock_mesh_2.set_surface_override_material(1, null)


func unlock_door():
	super()
	update_locked_unlocked_door_materials()


func lock_door():
	super()
	update_locked_unlocked_door_materials()


func force_locked():
	super()
	update_locked_unlocked_door_materials()


func clear_force_locked():
	super()
	update_locked_unlocked_door_materials()
