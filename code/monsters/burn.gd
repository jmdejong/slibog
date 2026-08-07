extends Area3D

var effect_damage: float = 50

func _physics_process(delta: float) -> void:
	
	for area: Area3D in get_overlapping_areas():
		var victim: Node3D = area.get_parent()
		if victim.dead:
			continue
		var direction: Vector3 = victim.global_position - global_position
		direction.y = 0;
		victim.hit(effect_damage * delta, Vector3.ZERO, null)
