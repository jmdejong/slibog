extends Control

#signal artificial_input
#signal rotate_view(drot: Vector2)
#@onready var touch_ui: TouchUi = $TouchUi

@export var faded: float = 0:
	set(val):
		faded = val
		fade(val)
var hurt: float = 0
var health: float = 1
var max_health: float = 1
var actual_hurt: float = 0

func _process(delta: float) -> void:
	var health_hurt: float = clamp((0.5-health / max_health) * 1.5, 0, 1)
	var total_hurt: float = hurt * 1.5 + health_hurt
	if total_hurt > actual_hurt:
		actual_hurt = min(total_hurt, actual_hurt + 10 * max(delta, (total_hurt-actual_hurt)/10))
	else:
		actual_hurt = max(total_hurt, actual_hurt - 10 * delta)
	$Hurt.visible = actual_hurt > 0
	$Hurt.material.set_shader_parameter("hurt", actual_hurt)
	hurt = max(hurt - delta, 0)

func fade(value: float) -> void:
	$Fade.visible = value > 0
	$Fade.material.set_shader_parameter("faded", value)

func set_hurt(damage: float) -> void:
	hurt = max(hurt, damage / max_health)

func set_info_text(text: String) -> void:
	%Info.text = text

func set_health(health: float, max_health: float) -> void:
	self.health = health
	self.max_health = max_health
	%HealthBar.offset_right = %HealthBar.offset_left + 3 * max_health
	%HealthMarker.anchor_right = clamp(health / max_health, 0, 1)

func set_stamina(stamina: float, max_stamina: float) -> void:
	%StaminaBar.offset_right = %StaminaBar.offset_left + 3 * max_stamina
	%StaminaMarker.anchor_right = clamp(stamina / max_stamina, 0, 1)

func set_xp(xp: float, max_xp: float) -> void:
	%XpMarker.anchor_right = clamp(xp / max_xp, 0, 1)

func set_level(level: int) -> void:
	%PlayerLevel.text = str(level)

func level_up(level: int) -> void:
	add_child(Notification.create("Level " + str(level) + "!"))
	
