class_name World
extends Node3D

func set_player(player: Player) -> void:
	for child in $Players.get_children():
		child.queue_free()
	$Players.add_child(player)

static func setup(player_class: PlayerClass, blueprint: LevelBlueprint, world_seed: int) -> World:
	var world: World = preload("res://scenes/world.tscn").instantiate()
	var level: Node3D = blueprint.generate(world_seed)
	world.add_child(level)
	var player: Player = player_class.player()
	player.transform = level.get_node("Spawn").transform
	world.set_player(player)
	return world
	#get_tree().change_scene_to_node(world)
