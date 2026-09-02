class_name PlayerClass
extends Node3D

@export var display_name: String
@export var weapon: PackedScene

const player_scene: PackedScene = preload("res://scenes/player.tscn")

func preview() -> Node3D:
	return $Preview.duplicate()
	
func player() -> Player:
	var p: Player = player_scene.instantiate()
	p.set_weapon(weapon.instantiate())
	p.player_class = self
	return p
