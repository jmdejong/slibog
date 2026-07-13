class_name World
extends Node3D

func set_player(player: Player) -> void:
	for child in $Players.get_children():
		child.queue_free()
	$Players.add_child(player)
