extends PickupItem

@export var health: float = 10
@export var lifetime: float = 60

func pickup(player: Player) -> void:
	if player.health >= player.max_health:
		return
	player.health = min(player.health + health, player.max_health)
	queue_free()

func _process(delta: float) -> void:
	$MeshInstance3D.rotate_y(delta * PI / 10)
	lifetime -= delta
	if lifetime < 0:
		$MeshInstance3D.position.y = lifetime
	if lifetime < -2:
		queue_free()
