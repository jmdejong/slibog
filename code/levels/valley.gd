extends LevelBlueprint

const level_size: float = 256
const area_axis_count: int = 4
const area_size: float = level_size / area_axis_count
const area_segments: int = 8

enum AreaType {Spawn, Forest, Bushy, Rocky, Grass}

func generate(world_seed: int) -> Node3D:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = world_seed
	var world: Node3D = Node3D.new()
	world.add_child(%WorldEnvironment.duplicate())
	var spawn: Node3D = Node3D.new()
	spawn.name = "Spawn"
	spawn.position = Vector3(0, 2, 0)
	world.add_child(spawn)
	for x: int in range(0, area_axis_count):
		for y: int in range(0, area_axis_count):
			generate_area(world, Vector2i(x, y), rng)
	var boundary_body: StaticBody3D = StaticBody3D.new()
	for n: Vector3 in [Vector3(1, 0, 0), Vector3(-1, 0, 0), Vector3(0, 0, 1), Vector3(0, 0,-1)]:
		var boundary_shape: CollisionShape3D = CollisionShape3D.new()
		var world_boundary: WorldBoundaryShape3D = WorldBoundaryShape3D.new()
		world_boundary.plane = Plane(n)
		boundary_shape.shape = world_boundary
		boundary_shape.position = n.posmod(level_size)
		boundary_body.add_child(boundary_shape)
	world.add_child(boundary_body)
		
	return world

func generate_area(world: Node3D, area_id: Vector2i, rng: RandomNumberGenerator) -> void:
	var area: Rect2 = Rect2(Vector2(area_id) * area_size, Vector2.ONE * area_size)
	var center2: Vector2 = area.get_center()
	var center: Vector3 = Vector3(center2.x, 1, center2.y)
	generate_ground(world, area)
	if area_id == Vector2i.ZERO:
		# spawn area
		var subtiles: int = 8
		var tile_size: float = area_size / subtiles
		var spawn_tile: Vector2i = Vector2i(subtiles / 2, subtiles / 2)
		var spawn_pos: Vector2 = area.position + tile_size * (Vector2(spawn_tile) + Vector2.ONE/2)
		world.get_node("Spawn").position = Vector3(spawn_pos.x, 2, spawn_pos.y)
		world.get_node("Spawn").rotation.y = PI * 5 / 4
		for x: int in subtiles:
			for y: int in subtiles:
				var tile: Vector2i = Vector2i(x, y)
				if abs(x - spawn_tile.x) <= 1 and abs(y - spawn_tile.y) <=1 :
					continue
				var pos2: Vector2 = area.position + tile_size * Vector2(tile) + Vector2(rng.randf_range(0.2, 0.8), rng.randf_range(0.2, 0.8))
				var pos: Vector3 = Vector3(pos2.x, 1, pos2.y)
				var r: float = rng.randf()
				var struct: Node3D = null
				if r < 0.05:
					struct = preload("res://scenes/structures/small_rock.tscn").instantiate()
				elif r < 0.075:
					struct = preload("res://scenes/structures/rock.tscn").instantiate()
				elif r < 0.1:
					struct = preload("res://scenes/structures/rock2.tscn").instantiate()
				elif r < 0.2:
					struct = preload("res://scenes/structures/tree.tscn").instantiate()
				elif r < 0.3:
					struct = preload("res://scenes/structures/small_tree.tscn").instantiate()
				if struct != null:
					struct.position = pos
					struct.rotation.y = rng.randf_range(-PI, PI)
					world.add_child(struct)
	else:
		var subtiles: int = 8
		var tile_size: float = area_size / subtiles
		var danger: int = clamp(area_id.x + area_id.y + rng.randi_range(-1, 1), 0, 5)
		var monster_chance: float = danger / 20.0
		var primary_enemy: PackedScene = preload("res://scenes/monsters/arm_ball.tscn")
		if danger > 3:
			var r: float = rng.randf()
			if r < 0.3:
				primary_enemy = preload("res://scenes/monsters/balrus.tscn")
			else:
				primary_enemy = preload("res://scenes/monsters/beaksheep.tscn")
		var secondary_enemy: PackedScene = preload("res://scenes/monsters/arm_ball.tscn")
		var area_type: AreaType = [
			AreaType.Forest,
			AreaType.Bushy,
			AreaType.Rocky,
			AreaType.Grass
		][rng.randi_range(0, 3)]
		var spawner: Node3D = preload("res://scenes/spawner.tscn").instantiate()
		spawner.position = center
		world.add_child(spawner)
		for x: int in range(1, subtiles):
			for y: int in range(1, subtiles):
				var tile: Vector2i = Vector2i(x, y)
				var pos2: Vector2 = area.position + tile_size * (Vector2(tile) + Vector2(rng.randf_range(0.2, 0.8), randf_range(0.2, 0.8)))
				var pos: Vector3 = Vector3(pos2.x, 1, pos2.y)
				var r: float = rng.randf()
				if r < monster_chance:
					var monster: Monster
					if rng.randf() < 0.6:
						monster = primary_enemy.instantiate()
					else:
						monster = secondary_enemy.instantiate()
					monster.position = pos - center
					monster.rotation.y = rng.randf_range(-PI, PI)
					spawner.add_child(monster)
				else:
					var struct: Node3D = null
					if area_type == AreaType.Forest:
						if r > 0.85:
							struct = preload("res://scenes/structures/small_tree.tscn").instantiate()
						elif r > 0.6:
							struct = preload("res://scenes/structures/tree.tscn").instantiate()
						elif r > 0.5:
							struct = preload("res://scenes/structures/bush.tscn").instantiate()
					elif area_type == AreaType.Bushy:
						if r > 0.9:
							struct = preload("res://scenes/structures/small_tree.tscn").instantiate()
						elif r > 0.8:
							struct = preload("res://scenes/structures/tree.tscn").instantiate()
						elif r > 0.75:
							struct = preload("res://scenes/structures/small_rock.tscn").instantiate()
						elif r > 0.6:
							struct = preload("res://scenes/structures/bush.tscn").instantiate()
					elif area_type == AreaType.Rocky:
						if r > 0.9:
							struct = preload("res://scenes/structures/rock2.tscn").instantiate()
						elif r > 0.7:
							struct = preload("res://scenes/structures/rock.tscn").instantiate()
						elif r > 0.6:
							struct = preload("res://scenes/structures/small_rock.tscn").instantiate()
						elif r > 0.55:
							struct = preload("res://scenes/structures/bush.tscn").instantiate()
					elif area_type == AreaType.Grass:
						if r > 0.95:
							struct = preload("res://scenes/structures/small_tree.tscn").instantiate()
						elif r > 0.9:
							struct = preload("res://scenes/structures/tree.tscn").instantiate()
						elif r > 0.85:
							struct = preload("res://scenes/structures/bush.tscn").instantiate()
					if struct != null:
						struct.position = pos
						struct.rotation.y = rng.randf_range(-PI, PI)
						world.add_child(struct)

func generate_ground(world: Node3D, area: Rect2) -> void:
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
	world.add_child(ground)
	var ground_mesh: MeshInstance3D = MeshInstance3D.new()
	var mesh: PlaneMesh = PlaneMesh.new()
	mesh.size = area.size
	mesh.subdivide_width = 15
	mesh.subdivide_depth = 15
	ground_mesh.mesh = mesh
	ground_mesh.material_override = preload("res://materials/static/ground_grass.tres")
	ground_mesh.position = Vector3(center.x, 1, center.y)
	world.add_child(ground_mesh)
