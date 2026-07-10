extends Node3D

@export var creature: PackedScene
@export var count: int = 3
@export var roam_range: float = 10
@export var respawn_time: float = 60
@export var initial_spawn: bool = true
var planned: int = 0;

var spawned: Array = []

func _ready() -> void:
	if initial_spawn:
		for i in count:
			spawn()

func tick() -> void:
	spawned = spawned.filter(is_instance_valid)
	if spawned.size() + planned < count:
		plan_spawn()
	

func plan_spawn() -> void:
	planned += 1
	await get_tree().create_timer(respawn_time).timeout
	planned -= 1
	spawn()

func spawn() -> void:
	var n = creature.instantiate()
	spawned.append(n)
	n.home = self
	n.position = global_position + Vector3.FORWARD.rotated(Vector3.UP, randf() * 2 * PI) * sqrt(randf() * roam_range)
	get_node("/root/World/Creatures").add_child(n)
