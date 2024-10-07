class_name AreaOfEffectIndicator extends MeshInstance3D

const CIRCLE_RADIUS = 2.0 * PI

# Define properties
var points_array = [] # Array of points
var center_point = Vector3(0, 0, 0) # Center point

# PackedVector**Arrays for mesh construction.
var verts = PackedVector3Array()
var uvs = PackedVector2Array()
var normals = PackedVector3Array()
var indices = PackedInt32Array()
var surface_array = []

@export var custom_material : Material
@export_flags_3d_physics var collide_mask


@export var radius = 5.0
@export var rings : int = 10
@export var radial_segments : int = 10

@export var use_sphere = false

@export var granularity : int = 100

## bespoke as a variable when set to true indicates that the AreaOfEffectIndicator uses a
## completely custom mesh/visuals. Therefore, no custom mesh nor modification of the mesh
## with collisions should be done. We use bespoke AoE Indicators for when we don't care about
## collisions and we want an interesting visual effect for the indicator. This way bespoke AoE indicators
## are compatible with the AoE prediction master while also not using our collision incorporating but less
## visually interesting AoE builder
@export var bespoke : bool = false


func _ready():
	pass


func generate_indicator():
	# If we have a bespoke indicator we do not want to regenerate it at all
	if not bespoke:
		array_setup()
		if use_sphere:
			generate_sphere_data()
		else:
			generate_circle_data()
		generate_mesh()


func array_setup():
	surface_array.clear()
	verts.clear()
	uvs.clear()
	normals.clear()
	indices.clear()
	surface_array.resize(Mesh.ARRAY_MAX)


func generate_sphere_data():
	# Vertex indices.
	var thisrow = 0
	var prevrow = 0
	var point = 0

	# Loop over rings.
	for i in range(rings + 1):
		var v = float(i) / rings
		var w = sin(PI * v)
		var y = cos(PI * v)

		# Loop over segments in ring.
		for j in range(radial_segments + 1):
			var u = float(j) / radial_segments
			var x = sin(u * PI * 2.0)
			var z = cos(u * PI * 2.0)
			var vert = generate_ray_casted_vert(Vector3(x * radius * w, y * radius, z * radius * w))
			verts.append(vert)
			normals.append(vert.normalized())
			uvs.append(Vector2(u, v))
			point += 1

			# Create triangles in ring using indices.
			if i > 0 and j > 0:
				indices.append(prevrow + j - 1)
				indices.append(prevrow + j)
				indices.append(thisrow + j - 1)

				indices.append(prevrow + j)
				indices.append(thisrow + j)
				indices.append(thisrow + j - 1)

		prevrow = thisrow
		thisrow = point


func generate_ray_casted_vert(vert: Vector3, center : Vector3 = center_point, mask=collide_mask):
	var params := PhysicsRayQueryParameters3D.new()
	params.collision_mask = mask
	params.from = MathUtil.generate_point_at_LOS_height(to_global(center))
	params.to = MathUtil.generate_point_at_LOS_height(to_global(vert))
	
	var space_state := get_world_3d().direct_space_state
	var collision = space_state.intersect_ray(params)
	
	if collision:
		# Putting the collision position back on the ground
		var localized_position = to_local(collision.position)
		localized_position.y = vert.y
		return localized_position
	return vert


func generate_mesh():
	var new_mesh = ArrayMesh.new()
	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = null # uvs
	surface_array[Mesh.ARRAY_NORMAL] = null # normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	# No blendshapes, lods, or compression used.
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
	new_mesh.surface_set_material(0, custom_material)
	mesh=new_mesh


func generate_circle_data():
	verts.append(center_point)
	
	# Perform raycasts in a circle
	for i in range(granularity):
		# Calculate the angle for the current raycast
		var angle = (i / float(granularity)) * (CIRCLE_RADIUS)
		
		# Calculate the direction vector for the raycast
		var direction = Vector3(cos(angle), 0, sin(angle))
		
		# Calculate the end point of the raycast
		var end_point = center_point + direction * radius
		
		# Perform the raycast
		var vert = generate_ray_casted_vert(end_point)
		
		
		verts.append(vert)
		# normals.append(vert.normalized())
		# uvs.append(Vector2(vert.x, vert.z))

		# Create triangles in ring using indices.
		if i > 0:
			indices.append(i)
			indices.append(0)
			indices.append(i+1)
	
	indices.append(1)
	indices.append(0)
	indices.append(len(verts) - 1)
	

func generate_triangle_data():
	verts.append(center_point)
	verts.append(Vector3(1, 0, 0))
	verts.append(Vector3(1, 0, 1))
	
	# normals.append(center_point.normalized())
	# normals.append(Vector3(1, 0, 0).normalized())
	# normals.append(Vector3(0, 0, 1).normalized())
	
	indices.append(1)
	indices.append(0)
	indices.append(2)

	
	"""
	# Clear existing mesh data
	mesh = Mesh.new()
	
	# Create an empty array to hold vertices
	var vertices = []
	
	# Add center point
	vertices.append(center_point)
	
	# Add points from the array
	for point in points_array:
		vertices.append(point)
	
	# Create a surface array to hold the vertex indices
	var indices = []
	
	# Create triangles from vertices
	for i in range(1, vertices.size() - 1):
		indices.append(0) # Center point index
		indices.append(i)
		indices.append(i + 1)
		
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	# Add vertices and indices to the mesh
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	# Assign the mesh to the MeshInstance
	mesh = arr_mesh
"""















"""
@onready var AreaOfEffectMesh = $AOEMesh

@export var granularity : int = 30

const CIRCLE_ARC = 360
const DEFAULT_FACING = Vector3(1, 0, 0)

@export var thickness = 0.1
@export var height = 0.1

var center_point : Vector3
var edge_points : Array[Vector3]
var radius : float
var arc : float
var initial_facing : Vector3
var current_facing : Vector3


func generate_area_of_effect_indicator(effect_center : Vector3, effect_radius : float, effect_arc :float = CIRCLE_ARC, effect_facing : Vector3 = DEFAULT_FACING):
	center_point = effect_center
	edge_points.clear()
	radius = effect_radius
	arc = effect_arc
	initial_facing = effect_facing
	current_facing = initial_facing
	generate_edge_points()


func generate_edge_points():
	var rotation_increment = calculate_rotation_amount_per_raycast(radius)
	for x in range(granularity):
		edge_points.append(generate_edge_point_current_facing())
		current_facing = current_facing.rotated( Vector3.UP, rotation_increment)
	edge_points.append(generate_edge_point_current_facing())
	
   
func generate_edge_point_current_facing():
	var start_point = center_point
	var vector_to_end_point = current_facing.normalized() * radius
	var end_point = start_point + vector_to_end_point
	
	var collision_info = raycast(start_point, end_point)
	
	if collision_info:
		return adjust_point_to_height(collision_info.collision_point)
	return adjust_point_to_height(end_point)
	

func adjust_point_to_height(point : Vector3) -> Vector3:
	return Vector3(point.x, height, point.z)


func calculate_rotation_amount_per_raycast(total_radius : float):
	return total_radius / granularity


# By default, collides with only PhysicsBodies on layers #1 and #3. See the documentation for 
# PhysicsDirectSpaceState3D.intersect_ray() for the return value content.
func raycast(ray_start:Vector3, ray_end:Vector3, mask:int=0x5) -> Dictionary:
	var params := PhysicsRayQueryParameters3D.new()
	params.collision_mask = mask
	params.from = ray_start
	params.to = ray_end
	
	var space_state := get_world_3d().direct_space_state
	return space_state.intersect_ray(params)
"""
