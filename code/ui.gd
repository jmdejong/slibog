extends Control

@export var faded: float = 0:
	set(val):
		faded = val
		fade(val)

func set_health(health: float, max_health: float) -> void:
	%HealthBar.offset_right = %HealthBar.offset_left + 3 * max_health
	%HealthMarker.anchor_right = health / max_health

func fade(value: float) -> void:
	$Fade.material.set_shader_parameter("faded", value)
