extends Control


var classes: Array[PlayerClass] = [
	preload("res://scenes/player_classes/spearman.tscn").instantiate(),
	preload("res://scenes/player_classes/axeman.tscn").instantiate()
]

var levels: Array[LevelBlueprint] = [
	preload("res://scenes/levels/valley.tscn").instantiate(),
	preload("res://scenes/levels/sol.tscn").instantiate(),
	preload("res://scenes/levels/test_level.tscn").instantiate(),
]

var class_selector: int = 0
var level_selector: int = 0

func _ready() -> void:
	for i in classes.size():
		if classes[i].scene_file_path == State.state.selected_class:
			class_selector = i
	for i in levels.size():
		if levels[i].scene_file_path == State.state.selected_level:
			level_selector = i
	change_selected_class(0)
	change_selected_level(0)

func spawn_in_world() -> void:
	var world: World = World.setup(selected_level(), randi())
	world.add_new_player(selected_class())
	State.set_in_world(true)
	State.save_world(world.to_json())
	get_tree().change_scene_to_node(world)

func change_selected_class(d: int) -> void:
	class_selector = posmod(class_selector + d, classes.size())
	for child: Node in %ClassPreview.get_children():
		child.queue_free()
	%ClassPreview.add_child(selected_class().preview())
	State.set_selected_class(selected_class())

func selected_class() -> PlayerClass:
	return classes[class_selector]

func change_selected_level(d: int) -> void:
	level_selector = posmod(level_selector + d, levels.size())
	for child: Node in %LevelPreview.get_children():
		child.queue_free()
	%LevelPreview.add_child(selected_level().preview())
	State.set_selected_level(selected_level())

func selected_level() -> LevelBlueprint:
	return levels[level_selector]

func _process(delta: float) -> void:
	%ClassPreview.rotate_y(delta/6)
	%LevelPreview.rotate_y(delta/12)
	%Info.text = "fps: %3.1f" % Engine.get_frames_per_second()
