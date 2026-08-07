class_name LevelBlueprint
extends Node3D

@export var scene: PackedScene

func preview() -> Node3D:
	return $Preview.duplicate()

func generate() -> Node3D:
	return scene.instantiate()
