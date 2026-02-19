extends TextureRect

@onready var end_of_the_day: TextureRect = $"."
@onready var main_menu_scene = preload("res://scenes/main_menu.tscn")

func _on_player_controller_day_ended() -> void:
	end_of_the_day.visible = true


func _on_quit_button_button_down() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)


func _on_player_controller_day_changed() -> void:
	print("DISABLING STATE OF PANEL")
	end_of_the_day.visible = false
