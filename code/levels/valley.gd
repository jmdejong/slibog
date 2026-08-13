extends LevelBlueprint

const level_size: float = 256
const area_axis_count: int = 4
const area_size: float = level_size / area_axis_count
const area_segments: int = 8

func generate() -> Node3D:
	var world: Node3D = Node3D.new()
	world.add_child(%WorldEnvironment.duplicate())
	var spawn: Node3D = Node3D.new()
	spawn.name = "Spawn"
	spawn.position = Vector3(0, 2, 0)
	world.add_child(spawn)
	for x: int in range(0, area_axis_count):
		for y: int in range(0, area_axis_count):
			prints(x, y, Time.get_ticks_msec())
			generate_area(world, Vector2i(x, y))
	prints("done", Time.get_ticks_msec())
	return world

func generate_area(world: Node3D, area_id: Vector2i) -> void:
	var area: Rect2 = Rect2(Vector2(area_id) * area_size, Vector2.ONE * area_size)
	var ground: Node3D = generate_ground(area)
	if area_id == Vector2i.ZERO:
		# spawn area
		var subtiles: int = 8
		var tile_size: float = area_size / subtiles
		var spawn_tile: Vector2i = Vector2i(subtiles / 2, subtiles / 2)
		var spawn_pos: Vector2 = area.position + tile_size * (Vector2(spawn_tile) + Vector2.ONE/2)
		world.get_node("Spawn").position = Vector3(spawn_pos.x, 2, spawn_pos.y)
		for x: int in subtiles:
			for y: int in subtiles:
				var tile: Vector2i = Vector2i(x, y)
				if abs(x - spawn_tile.x) <= 1 and abs(y - spawn_tile.y) <=1 :
					continue
				var pos2: Vector2 = area.position + tile_size * Vector2(tile) + Vector2(randf_range(0.2, 0.8), randf_range(0.2, 0.8))
				var pos: Vector3 = Vector3(pos2.x, 1, pos2.y)
				var r: float = randf()
				var struct: Node3D = null
				if r < 0.1:
					struct = preload("res://scenes/structures/rock.tscn").instantiate()
				elif r < 0.2:
					struct = preload("res://scenes/structures/tree.tscn").instantiate()
				elif r < 0.3:
					struct = preload("res://scenes/structures/small_tree.tscn").instantiate()
				if struct != null:
					struct.position = pos
					struct.rotation.y = randf_range(-PI, PI)
					world.add_child(struct)
	else:
		var subtiles: int = 8
		var tile_size: float = area_size / subtiles
		for x: int in range(1, subtiles):
			for y: int in range(1, subtiles):
				var tile: Vector2i = Vector2i(x, y)
				var pos2: Vector2 = area.position + tile_size * (Vector2(tile) + Vector2(randf_range(0.2, 0.8), randf_range(0.2, 0.8)))
				var pos: Vector3 = Vector3(pos2.x, 1, pos2.y)
				var r: float = randf()
				var struct: Node3D = null
				if r < 0.25:
					struct = preload("res://scenes/structures/rock.tscn").instantiate()
				elif r < 0.5:
					struct = preload("res://scenes/structures/small_tree.tscn").instantiate()
				else:
					struct = preload("res://scenes/structures/tree.tscn").instantiate()
				if struct != null:
					struct.position = pos
					struct.rotation.y = randf_range(-PI, PI)
					world.add_child(struct)
	world.add_child(ground)

func generate_ground(area: Rect2) -> Node3D:
	var ground: StaticBody3D = StaticBody3D.new()
	var center: Vector2 = area.get_center()
	ground.position = Vector3(center.x, 0, center.y)
	var ground_shape: CollisionShape3D = CollisionShape3D.new()
	var step_size: float = area_size / area_segments
	ground_shape.scale = Vector3.ONE * step_size
	var heightmap: HeightMapShape3D = HeightMapShape3D.new()
	heightmap.map_depth = area_segments + 1
	heightmap.map_width = area_segments + 1
	var height_buffer: PackedFloat32Array = PackedFloat32Array()
	height_buffer.resize(heightmap.map_width * heightmap.map_depth)
	height_buffer.fill(1.0 / step_size)
	heightmap.map_data = height_buffer
	ground_shape.shape = heightmap
	ground.add_child(ground_shape)
	var ground_mesh: MeshInstance3D = MeshInstance3D.new()
	var mesh = PlaneMesh.new()
	mesh.size = area.size
	ground_mesh.mesh = mesh
	ground_mesh.material_override = preload("res://materials/static/ground_grass.tres")
	ground_mesh.position = Vector3(0, 1, 0)
	ground.add_child(ground_mesh)
	return ground
