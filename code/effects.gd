extends Node3D


func add_effect(effect: PackedScene, pos: Vector3) -> void:
	var node: Node3D = effect.instantiate()
	node.position = pos
	add_child(node)
