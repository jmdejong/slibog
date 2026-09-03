extends Node

var world: World
#var generate_progress()

func _ready() -> void:
	print("Starting slibog")
	#world = load("res://scenes/world.tscn").instantiate()
	initialize.call_deferred()

func initialize():
	await(get_tree().create_timer(0.2).timeout)
	if State.is_in_world():
		print("go to world")
		generate_world()
	else:
		print("go to menu")

func generate_world() -> void:
	var world_json: Variant = State.load_world()
	if world_json != null and world_json is Dictionary:
		print("load world from json")
		world = World.from_json(world_json)
	if world != null:
		get_tree().change_scene_to_node.call_deferred(world)
	else:
		printerr("failed loading world")
		get_tree().change_scene_to_file("res://scenes/main.tscn")


func _draw() -> void:
	pass
