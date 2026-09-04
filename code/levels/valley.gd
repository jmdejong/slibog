extends LevelWorld

const area_axis_count: int = 4
const area_size: float = 64
const area_segments: int = 8
const area_offset: float = 16
const area_total_size: float = area_size + area_offset
const level_size: float = area_total_size * area_axis_count
const map_areas: Rect2i = Rect2i(0, 0, area_axis_count, area_axis_count)

const TREE_SCENE: PackedScene = preload("res://scenes/structures/tree.tscn")
const SMALL_TREE_SCENE: PackedScene = preload("res://scenes/structures/small_tree.tscn")
const BUSH_SCENE: PackedScene = preload("res://scenes/structures/bush.tscn")
const ROCK_SCENE: PackedScene = preload("res://scenes/structures/rock.tscn")
const ROCK2_SCENE: PackedScene = preload("res://scenes/structures/rock2.tscn")
const SMALL_ROCK_SCENE: PackedScene = preload("res://scenes/structures/small_rock.tscn")


var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@export var edge_slope: Curve

func generate(world_seed: int, _modifiers: Variant) -> void:
	rng.seed = world_seed
	var areas: Dictionary[Vector2i, MapArea] = {}
	for x: int in range(0, area_axis_count):
		for y: int in range(0, area_axis_count):
			var area_id: Vector2i = Vector2i(x, y)
			areas[area_id] = generate_area(area_id)
	generate_heightmap(areas)

func generate_area(area_id: Vector2i) -> MapArea:
	var area: Rect2 = Rect2(Vector2(area_id) * area_total_size + Vector2.ONE * area_offset / 2, Vector2.ONE * area_size)
	var center2: Vector2 = area.get_center()
	var center: Vector3 = Vector3(center2.x, 1, center2.y)
	#generate_ground(world, area)
	var map_area: MapArea
	if area_id == Vector2i(0, 0):
		map_area = SpawnArea.new()
	else:
		map_area = [
			ForestArea.new(),
			BushyArea.new(),
			RockyArea.new(),
			GrassArea.new()
		][rng.randi() % 4]
	map_area.area_id = area_id
	map_area.center = center
	map_area.area_seed = rng.randi()
	map_area.radius = area_size / 2
	map_area.subtiles = 8
	map_area.danger = clamp(area_id.x + area_id.y + rng.randi_range(-1, 1), 0, 5)
	map_area.apply(self)
	return map_area

class MapArea:
	var center: Vector3
	var radius: float
	var subtiles: int
	var area_seed: int
	#var height: float
	var danger: int
	var area_id: Vector2i
	func positions() -> Array[Vector3]:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = hash(area_seed^12345)
		var pos_size = radius / subtiles
		var ps: Array[Vector3]
		var l: float = radius / pos_size
		for x: int in int(l * 2):
			for y: int in int(l * 2):
				var pos: Vector3 = center + (Vector3(x, 0, y) + Vector3(rng.randf_range(0.2, 0.8), 0, rng.randf_range(0.2, 0.8))) * pos_size - Vector3(radius, 0, radius)
				pos.y = center.y
				if pos.distance_to(center) > radius * 1.2:
					continue
				ps.append(pos)
		return ps
	
	func monster_pool() -> Array[PackedScene]:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = hash(area_seed^5781)
		var primary_enemy: PackedScene = preload("res://scenes/monsters/arm_ball.tscn")
		if danger > 3:
			var r: float = rng.randf()
			if r < 0.3:
				primary_enemy = preload("res://scenes/monsters/balrus.tscn")
			else:
				primary_enemy = preload("res://scenes/monsters/beaksheep.tscn")
		var secondary_enemy: PackedScene = preload("res://scenes/monsters/arm_ball.tscn")
		var pool: Array[PackedScene]
		for i in range(danger * 2):
			pool.append(primary_enemy)
		for i in range(danger):
			pool.append(secondary_enemy)
		return pool
	
	func structure_pool() -> Array[PackedScene]:
		return []
	
	func feature_pool() -> Array[PackedScene]:
		return monster_pool() + structure_pool()
	
	func apply(world: Node3D) -> void:
		var spawner: Node3D = preload("res://scenes/spawner.tscn").instantiate()
		spawner.position = center
		world.add_child(spawner)
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = hash(area_seed ^ 84728)
		var position_pool: Array[Vector3] = positions()
		for feature: PackedScene in feature_pool():
			if position_pool.is_empty():
				printerr("Not enough positions for area " + str(self) + " at " + str(area_id))
				break
			var i: int = rng.randi() % position_pool.size()
			var pos: Vector3
			if i == position_pool.size() - 1:
				pos = position_pool.pop_back()
			else:
				pos = position_pool[i]
				position_pool[i] = position_pool.pop_back()
			var node: Node3D = feature.instantiate()
			node.position = pos
			node.rotate_y(randf() * 2 * PI)
			if node is Monster:
				node.position -= spawner.position
				spawner.add_child(node)
			else:
				world.add_child(node)
	
	func _fadd(pool: Array[PackedScene], feature: PackedScene, count: int) -> void:
		for _i: int in count:
			pool.append(feature)

class SpawnArea extends MapArea:
	func positions() -> Array[Vector3]:
		return super().filter(func(pos): return pos.distance_to(center) > radius / subtiles * 2)
	
	func monster_pool() -> Array[PackedScene]:
		return []
	
	func structure_pool() -> Array[PackedScene]:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = hash(area_seed^92384)
		var pool: Array[PackedScene] = []
		_fadd(pool, BUSH_SCENE, rng.randi_range(2, 5))
		_fadd(pool, SMALL_TREE_SCENE, rng.randi_range(1, 3))
		_fadd(pool, TREE_SCENE, rng.randi_range(2, 5))
		_fadd(pool, ROCK_SCENE, rng.randi_range(1, 3))
		_fadd(pool, ROCK2_SCENE, rng.randi_range(1, 3))
		_fadd(pool, SMALL_ROCK_SCENE, 4)
		return pool
	
	func apply(world: Node3D) -> void:
		super(world)
		var spawn_node = world.get_node("Spawn")
		spawn_node.position = center + Vector3(0, 2, 0)
		#spawn_node.look_at(Vector3(area.end.x, 2, area.end.y), Vector3.UP)
		spawn_node.rotate_y(PI * 5 / 4)

class ForestArea extends MapArea:
	func structure_pool() -> Array[PackedScene]:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = hash(area_seed^92384)
		var pool: Array[PackedScene] = []
		_fadd(pool, BUSH_SCENE, rng.randi_range(3, 8))
		_fadd(pool, SMALL_TREE_SCENE, rng.randi_range(8, 12))
		_fadd(pool, TREE_SCENE, rng.randi_range(15, 25))
		_fadd(pool, SMALL_ROCK_SCENE, rng.randi_range(0, 2))
		return pool

class BushyArea extends MapArea:
	func structure_pool() -> Array[PackedScene]:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = hash(area_seed^92384)
		var pool: Array[PackedScene] = []
		_fadd(pool, BUSH_SCENE, rng.randi_range(12, 20))
		_fadd(pool, SMALL_TREE_SCENE, rng.randi_range(2, 10))
		_fadd(pool, TREE_SCENE, rng.randi_range(1, 3))
		_fadd(pool, SMALL_ROCK_SCENE, rng.randi_range(1, 6))
		return pool

class RockyArea extends MapArea:
	func structure_pool() -> Array[PackedScene]:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = hash(area_seed^92384)
		var pool: Array[PackedScene] = []
		_fadd(pool, ROCK_SCENE, rng.randi_range(5, 15))
		_fadd(pool, ROCK2_SCENE, rng.randi_range(5, 15))
		_fadd(pool, BUSH_SCENE, rng.randi_range(3, 10))
		_fadd(pool, SMALL_ROCK_SCENE, rng.randi_range(5, 10))
		return pool

class GrassArea extends MapArea:
	func structure_pool() -> Array[PackedScene]:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = hash(area_seed^92384)
		var pool: Array[PackedScene] = []
		_fadd(pool, BUSH_SCENE, rng.randi_range(1, 4))
		_fadd(pool, SMALL_TREE_SCENE, rng.randi_range(0, 2))
		_fadd(pool, TREE_SCENE, rng.randi_range(0, 1))
		_fadd(pool, SMALL_ROCK_SCENE, rng.randi_range(1, 3))
		return pool

func generate_heightmap(areas: Dictionary[Vector2i, MapArea]) -> void:
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.seed = rng.randi()
	var mountain_noise: FastNoiseLite = FastNoiseLite.new()
	mountain_noise.seed = rng.randi()
	var terrain: HTerrain = $HTerrain;
	var terrain_data: HTerrainData = HTerrainData.new()
	terrain_data.resize(513)
	var heightmap: Image = terrain_data.get_image(HTerrainData.CHANNEL_HEIGHT)
	for z in heightmap.get_height():
		for x in heightmap.get_width():
			var pos3: Vector3 = Vector3(x, 0, z) * terrain.map_scale + terrain.position
			var pos: Vector2 = Vector2(pos3.x, pos3.z)
			#var  := fposmod(pos, area_size + area_offset)
			var nearest_area_id : Vector2i = Vector2i((pos / area_total_size).floor()).clampi(0, area_axis_count-1)
			var nearest_area: MapArea = areas[nearest_area_id]
			var nearest_area_distance: float = pos.distance_to((Vector2(nearest_area_id) + Vector2(0.5, 0.5)) * area_total_size)
			var t: float = clamp(
				(nearest_area_distance + noise.get_noise_2dv(pos*10) * 2 - area_total_size/2.0 - 1) / 10,
				0,
				1
			)
			var mn: float = mountain_noise.get_noise_2dv(pos)
			var h: float = lerpf(nearest_area.center.y, 20 + mn * mn * 50, edge_slope.sample(t))
			heightmap.set_pixel(x, z, Color(h / terrain.map_scale.y, 0, 0))
	
	var modified_region = Rect2(Vector2(), heightmap.get_size())
	terrain_data.notify_region_change(modified_region, HTerrainData.CHANNEL_HEIGHT)
	
	terrain.set_data(terrain_data)
	terrain.update_collider()
