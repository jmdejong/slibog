extends Node

var world: World
#var generate_progress()

func _ready() -> void:
	world = load("res://scenes/world.tscn").instantiate()
	generate_world.call_deferred()

func generate_world() -> void:
	var level: Node3D = load("res://scenes/levels/valley.tscn").instantiate().generate()
	world.add_child(level)
	var player: Player = load("res://scenes/player_classes/spearman.tscn").instantiate().player()
	player.position = level.get_node("Spawn").position
	world.set_player(player)
	start_world.call_deferred()

func start_world() -> void:
	get_tree().change_scene_to_node(world)

func _draw() -> void:
	pass
