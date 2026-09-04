extends Control


func end_run() -> void:
	$EndRun.visible = true
	await get_tree().create_timer(1).timeout
	%Return.visible = true

func return_to_main() -> void:
	Measure.start("open_menu")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func click_elsewhere() -> void:
	$SettingsButton.button_pressed = false
