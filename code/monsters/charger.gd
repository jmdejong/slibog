extends Monster

@export var charge_speed: float = 30
@export var charge_attack_speed = 0.333

var is_charging: bool = false
var cooldown: float = 0
var charge_vel: Vector3


func charge() -> void:
	charge_vel = (Vector3(target_pos.x, global_position.y, target_pos.z) - global_position).normalized() * charge_speed
	is_charging = true

func move_attack() -> void:
	if is_charging:
		velocity.x = charge_vel.x
		velocity.z = charge_vel.z

func stop_charge() -> void:
	reset_horizontal_velocity()
	is_charging = false

func post_process(delta: float) -> void:
	cooldown -= delta
	if is_charging:
		if cooldown <= 0 and behavior == Behavior.Attacking:
			var attacked: int = do_attack()
			if attacked > 0:
				cooldown = charge_attack_speed
		if Vector2(velocity.x, velocity.z).length() < charge_speed / 2:
			$AnimationPlayer.play_section_with_markers("attack", "charge_end")
