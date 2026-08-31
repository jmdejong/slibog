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

var spawned: Array[Monster] = []
var blueprints: Array[Monster] = []


func _ready() -> void:
	for child: Node in get_children():
		if child is Monster:
			var s: SpawnData = SpawnData.new(child.duplicate())
			s.spawned = child
			child.home = self
			spawns.append(s)

func tick() -> void:
	for s: SpawnData in spawns:
		if s.spawned != null and is_instance_valid(s.spawned) and !s.spawned.dead:
			s.last_seen_ms = Time.get_ticks_msec()
		elif s.last_seen_ms < Time.get_ticks_msec() - respawn_time_ms and far_enough_from_player(s):
			spawn(s)
			return

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
