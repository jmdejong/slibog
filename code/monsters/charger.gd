extends Monster

@export var charge_speed: float = 30
@export var charge_attack_speed = 0.333

var is_charging: bool = false
var cooldown: float = 0

func charge() -> void:
	var dif = target_pos - global_position
	horizontal_velocity = Vector3(dif.x, 0, dif.z).normalized() * charge_speed
	is_charging = true

func stop_charge() -> void:
	horizontal_velocity = Vector3.ZERO
	is_charging = false

func post_process(delta: float) -> void:
	cooldown -= delta
	if is_charging and cooldown <= 0:
		var attacked: int = do_attack()
		if attacked > 0:
			cooldown = charge_attack_speed
