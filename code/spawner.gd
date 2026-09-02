extends Node3D

@export var roam_range: float = 32
@export var respawn_time_ms: int = 300_000
@export var initial_spawn: bool = true
@export var clear_radius: float = 48

class SpawnData:
	var blueprint: Monster
	var spawned: Monster = null
	var last_seen_ms: int = -1_000_000_000
	func _init(blueprint_: Monster) -> void:
		blueprint = blueprint_

var spawns: Array[SpawnData] = []

func _ready() -> void:
	for child: Node in get_children():
		if child is Monster:
			var s: SpawnData = SpawnData.new(child)
			remove_child(child)
			spawns.append(s)
	var first_tick: SceneTreeTimer = get_tree().create_timer(0.5, false)
	first_tick.timeout.connect(tick)

func tick() -> void:
	var spawned_normal: bool = false
	for s: SpawnData in spawns:
		if s.spawned != null and is_instance_valid(s.spawned) and !s.spawned.dead:
			s.last_seen_ms = Time.get_ticks_msec()
			continue
		if not far_enough_from_player(s):
			continue
		var time_since_last_seen: int = Time.get_ticks_msec() - s.last_seen_ms
		if time_since_last_seen > respawn_time_ms * 2:
			spawn(s)
		elif time_since_last_seen > respawn_time_ms and not spawned_normal:
			spawn(s)
			spawned_normal = true

func far_enough_from_player(s: SpawnData) -> bool:
	var spawn_pos: Vector3 = global_transform * s.blueprint.position
	for area: Area3D in $Observe.get_overlapping_areas():
		var ppos: Vector3 = area.get_parent().global_position
		if ppos.distance_to(spawn_pos) < clear_radius:
			return false
	return true
	

func spawn(s: SpawnData) -> void:
	var monster: Monster = s.blueprint.duplicate()
	s.spawned = monster
	monster.home = self
	add_child(monster)

func observing_players() -> Array[Player]:
	var players: Array[Player] = []
	players.append_array($Observe.get_overlapping_areas().map(func(area: Area3D): return area.get_parent()))
	return players

func id() -> String:
	return str(global_position)

func set_from_json(json: Dictionary):
	var monsters_json = json.get(id())
	if monsters_json == null:
		return
	for i: int in monsters_json.size():
		if i >= spawns.size():
			break
		var data: SpawnData = spawns[i]
		var monster_json: Variant = monsters_json[i]
		if monster_json == null or not monster_json is Dictionary:
			if data.spawned != null:
				data.spawned.queue_free()
				data.spawned = null
			continue
		if data.spawned == null:
			spawn(data)
		data.spawned.set_from_json(monster_json)

func is_active() -> bool:
	if $Observe.has_overlapping_areas():
		return true
	for s: SpawnData in spawns:
		if s.spawned != null and s.spawned.behavior != Monster.Behavior.Sleeping:
			return true
	return false

func to_json() -> Variant:
	if not is_active():
		return null
	var monsters_json: Array = []
	for data: SpawnData in spawns:
		if data.spawned == null:
			monsters_json.append(null)
		else:
			monsters_json.append(data.spawned.to_json())
	return monsters_json

func add_json(all_json: Dictionary) -> void:
	var json = to_json()
	if json != null:
		all_json[id()] = json	
