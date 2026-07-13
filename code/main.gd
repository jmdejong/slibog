extends Control


var classes: Array[PlayerClass] = [
	preload("res://scenes/player_classes/spearman.tscn").instantiate(),
	preload("res://scenes/player_classes/axeman.tscn").instantiate()
]

var class_selector: int = 0

func _ready() -> void:
	change_selected_class(0)

func spawn_in_world() -> void:
	var world: World = preload("res://scenes/world.tscn").instantiate()
	world.set_player(selected_class().player())
	get_tree().change_scene_to_node(world)

func change_selected_class(d: int) -> void:
	class_selector = posmod(class_selector + d, classes.size())
	for child: Node in %ClassPreview.get_children():
		child.queue_free()
	%ClassPreview.add_child(selected_class().preview())

func selected_class() -> PlayerClass:
	return classes[class_selector]
