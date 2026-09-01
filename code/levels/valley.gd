extends LevelBlueprint

const area_axis_count: int = 4
const area_size: float = 64
const area_segments: int = 8
const area_offset: float = 16
const area_total_size: float = area_size + area_offset
const level_size: float = area_total_size * area_axis_count
const map_areas: Rect2i = Rect2i(0, 0, area_axis_count, area_axis_count)

@export var edge_slope: Curve

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
	generate_heightmap(world)
	for x: int in range(0, area_axis_count):
		for y: int in range(0, area_axis_count):
			generate_area(world, Vector2i(x, y), rng)
	return world

func generate_area(world: Node3D, area_id: Vector2i, rng: RandomNumberGenerator) -> void:
	var area: Rect2 = Rect2(Vector2(area_id) * area_total_size + Vector2.ONE * area_offset / 2, Vector2.ONE * area_size)
	var center2: Vector2 = area.get_center()
	var center: Vector3 = Vector3(center2.x, 1, center2.y)
	#generate_ground(world, area)
	if area_id == Vector2i.ZERO:
		# spawn area
		var subtiles: int = 8
		var tile_size: float = area_size / subtiles
		var spawn_tile: Vector2i = Vector2i(subtiles / 2, subtiles / 2)
		var spawn_pos: Vector2 = area.position + tile_size * (Vector2(spawn_tile))
		var spawn_node: Node3D = world.get_node("Spawn")
		spawn_node.position = Vector3(spawn_pos.x, 2, spawn_pos.y)
		#spawn_node.look_at(Vector3(area.end.x, 2, area.end.y), Vector3.UP)
		spawn_node.rotate_y(PI * 5 / 4)
		for x: int in subtiles:
			for y: int in subtiles:
				var tile: Vector2i = Vector2i(x, y)
				if abs(x - spawn_tile.x) <= 1 and abs(y - spawn_tile.y) <=1 :
					continue
				var pos2: Vector2 = area.position + tile_size * (Vector2(tile) + Vector2(rng.randf_range(0.2, 0.8), randf_range(0.2, 0.8)))
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
		for x: int in range(subtiles):
			for y: int in range(subtiles):
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


func generate_heightmap(world: Node3D) -> void:
	var terrain: HTerrain = $HTerrain.duplicate();
	var terrain_data: HTerrainData = HTerrainData.new()
	terrain_data.resize(513)
	var heightmap: Image = terrain_data.get_image(HTerrainData.CHANNEL_HEIGHT)
	for z in heightmap.get_height():
		for x in heightmap.get_width():
			var h: float = 1
			var pos3: Vector3 = Vector3(x, 0, z) * terrain.map_scale + terrain.position
			var pos: Vector2 = Vector2(pos3.x, pos3.z)
			#var  := fposmod(pos, area_size + area_offset)
			var nearest_area_id : Vector2i = Vector2i((pos / area_total_size).floor()).clampi(0, area_axis_count-1)
			var nearest_area_distance: float = pos.distance_to((Vector2(nearest_area_id) + Vector2(0.5, 0.5)) * area_total_size)
			var t: float = clamp((nearest_area_distance - area_total_size/2.0 - 1) / 10, 0, 1)
			h = lerpf(1, 30, edge_slope.sample(t))
			heightmap.set_pixel(x, z, Color(h / terrain.map_scale.y, 0, 0))
	
	var modified_region = Rect2(Vector2(), heightmap.get_size())
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
	
	terrain.set_data(terrain_data)
	terrain.update_collider()
	world.add_child(terrain)
