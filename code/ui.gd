extends Control

@export var faded: float = 0:
	set(val):
		faded = val
		fade(val)

func set_health(health: float, max_health: float) -> void:
	%HealthBar.offset_right = %HealthBar.offset_left + 3 * max_health
	%HealthMarker.anchor_right = health / max_health

func set_stamina(stamina: float, max_stamina: float) -> void:
	%StaminaBar.offset_right = %StaminaBar.offset_left + 3 * max_stamina
	%StaminaMarker.anchor_right = stamina / max_stamina

func fade(value: float) -> void:
	$Fade.visible = value > 0
	$Fade.material.set_shader_parameter("faded", value)

func end_run() -> void:
	$EndRun.visible = true
	await get_tree().create_timer(1).timeout
	%Return.visible = true

func return_to_main() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
