class_name LevelWorld
extends Node3D

@export var version: int = 0

func spawn_transform() -> Transform3D:
	return $Spawn.transform

func generate(_seed: int, _modifiers: Variant) -> void:
	pass
