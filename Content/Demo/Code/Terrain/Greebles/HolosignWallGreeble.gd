extends Node3D

@export var invert_direction : bool = false
# @export var text : String = "EMPLOYEES -->"

@onready var text_mesh : MeshInstance3D = $TextMesh

func _ready() -> void:
	# Setting the text mid game seems to occasionally cause issues
	# text_mesh.mesh.text = text
	var shimmer_shader : ShaderMaterial = text_mesh.mesh.surface_get_material(0).next_pass
	
	if invert_direction:
		shimmer_shader.set_shader_parameter("invert_direction", -1.0)
	else:
		shimmer_shader.set_shader_parameter("invert_direction", 1.0)
