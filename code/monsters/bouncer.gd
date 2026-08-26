extends Monster

@export var jump_speed: float = 7

func _ready() -> void:
	velocity.y = randf_range(0, jump_speed)

func start_walk() -> void:
	look_at(Vector3(target_pos.x, position.y, target_pos.z))
	walk_to(target_pos, speed)

func walk() -> void:
	pass


func post_process(_delta: float) -> void:
	if is_on_floor() and velocity.y <= 0 and not dead:
		plan()
		velocity.y = jump_speed

func start_attack() -> void:
	walk_to(target_pos, speed)
	
