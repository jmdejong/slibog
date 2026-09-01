class_name LootEntry
extends Resource

@export var chance: float = 0
@export var item: PackedScene = null
#func _init(item_: PackedScene, chance_: float) -> void:
	#chance = chance_
	#item = item_
