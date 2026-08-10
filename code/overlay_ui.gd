extends Control

#signal artificial_input
#signal rotate_view(drot: Vector2)
#@onready var touch_ui: TouchUi = $TouchUi

@export var faded: float = 0:
	set(val):
		faded = val
		fade(val)

func fade(value: float) -> void:
	$Fade.visible = value > 0
	$Fade.material.set_shader_parameter("faded", value)


func set_info_text(text: String) -> void:
	%Info.text = text

func set_health(health: float, max_health: float) -> void:
	%HealthBar.offset_right = %HealthBar.offset_left + 3 * max_health
	%HealthMarker.anchor_right = health / max_health

func set_stamina(stamina: float, max_stamina: float) -> void:
	%StaminaBar.offset_right = %StaminaBar.offset_left + 3 * max_stamina
	%StaminaMarker.anchor_right = stamina / max_stamina



		
