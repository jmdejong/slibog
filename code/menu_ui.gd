extends Control


func end_run() -> void:
	$EndRun.visible = true
	await get_tree().create_timer(1).timeout
	%Return.visible = true

func return_to_main() -> void:
	Measure.start("open_menu")
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func click_elsewhere() -> void:
	$SettingsMenu.click_elsewhere()
	
func show_death_stats(level: int, xp: float, legacy: int) -> void:
	%LevelCounter.text = str(level)
	%XpCounter.text = str(int(floor(xp)))
	%LegacyCounter.text = str(legacy)
	
