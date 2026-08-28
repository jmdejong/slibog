class_name LevelBlueprint
extends Node3D

@export var scene: PackedScene
@export var display_name: String

func preview() -> Node3D:
	return $Preview.duplicate()

func generate(_seed: int) -> Node3D:
	return scene.instantiate()

func name() -> String:
	return display_name
	
