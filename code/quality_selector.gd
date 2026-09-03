extends OptionButton

func _ready() -> void:
	select(get_item_index(Config.performance))


func _on_item_selected(index: int) -> void:
	Config.set_performance(get_item_id(index))
