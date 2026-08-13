extends Node3D

#@export var creature: PackedScene
#@export var count: int = 3
@export var roam_range: float = 10
@export var respawn_time: float = 60
@export var initial_spawn: bool = true
#var planned: int = 0;

var spawned: Array[Monster] = []
var blueprints: Array[Monster] = []

func _ready() -> void:
	for child: Node in get_children():
		if child is Monster:
			spawned.append(child)
			blueprints.append(child.duplicate())

func tick() -> void:
	for i in spawned.size():
		var monster: Monster = spawned[i]
		if monster != null and (!is_instance_valid(monster) or monster.dead):
			spawned[i] = null
			plan_spawn(i)
			
			
	#spawned = spawned.filter(is_instance_valid)
	#if spawned.size() + planned < count:
		#plan_spawn()
	

func plan_spawn(index: int) -> void:
	#planned += 1
	await get_tree().create_timer(respawn_time).timeout
	#planned -= 1
	spawn(index)

func spawn(index: int) -> void:
	#var n = creature.instantiate()
	var n = blueprints[index].duplicate()
	spawned[index] = n
	n.home = self
	n.position = global_position + Vector3.FORWARD.rotated(Vector3.UP, randf() * 2 * PI) * sqrt(randf() * roam_range)
	get_node("/root/World/Creatures").add_child(n)
