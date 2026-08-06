extends Monster

@export var jump_speed: float = 7

func start_walk() -> void:
	look_at(Vector3(target_pos.x, position.y, target_pos.z))
	velocity = (target_pos - global_position).normalized() * speed

func walk() -> void:
	pass


func post_process() -> void:
	if is_on_floor() and velocity.y <= 0 and not dead:
		plan()
		velocity.y = jump_speed

func start_attack() -> void:
	look_at(Vector3(target_pos.x, position.y, target_pos.z))
	velocity = (target_pos - global_position).normalized() * speed
	
