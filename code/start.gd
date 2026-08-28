extends Node

var world: World
#var generate_progress()

func _ready() -> void:
	#world = load("res://scenes/world.tscn").instantiate()
	if State.is_in_world():
		generate_world.call_deferred()
	else:
		get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")

func generate_world() -> void:
	world = World.setup(
		State.selected_class(),
		State.selected_level(),
		randi()
	)
	start_world.call_deferred()

func start_world() -> void:
	get_tree().change_scene_to_node(world)

func _draw() -> void:
	pass
