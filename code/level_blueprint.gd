class_name LevelBlueprint
extends Node3D

@export_file var scene_file: String
@export var display_name: String

func generate(world_seed: int) -> Node3D:
	var scene: LevelWorld = load(scene_file).instantiate()
	scene.generate(world_seed, null)
	return scene

func name() -> String:
	return display_name
