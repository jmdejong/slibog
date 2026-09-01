class_name World
extends Node3D

var blueprint: LevelBlueprint
var world_seed: int
var player_to_spawn: PlayerClass

func _ready() -> void:
	var level: Node3D = blueprint.generate(world_seed)
	add_child(level)
	var player: Player = player_to_spawn.player()
	player.transform = level.get_node("Spawn").transform
	$Players.add_child(player)


static func setup(player_class: PlayerClass, blueprint_: LevelBlueprint, world_seed_: int) -> World:
	var world: World = preload("res://scenes/world.tscn").instantiate()
	world.blueprint = blueprint_
	world.world_seed = world_seed_
	world.player_to_spawn = player_class
	return world
