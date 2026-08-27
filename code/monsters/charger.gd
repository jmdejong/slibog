extends Monster

@export var charge_speed: float = 30
@export var charge_attack_speed = 0.333

var is_charging: bool = false
var cooldown: float = 0


func charge() -> void:
	walk_to(target_pos, charge_speed)
	is_charging = true

func stop_charge() -> void:
	reset_horizontal_velocity()
	is_charging = false

func post_process(delta: float) -> void:
	cooldown -= delta
	if is_charging and cooldown <= 0 and behavior == Behavior.Attacking:
		var attacked: int = do_attack()
		if attacked > 0:
			cooldown = charge_attack_speed
