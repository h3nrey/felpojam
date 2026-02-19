extends HBoxContainer
@onready var label: Label = $Label



func _on_player_controller_lives_changed(curr_lives: Variant) -> void:
	label.text = str(curr_lives)
