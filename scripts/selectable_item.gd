extends Node

@export var item = ""
@export var value = ""
@onready var selectable_item: Button = $"."

func _ready():
	selectable_item.text = value

func select_item():
	SelectItem.on_item_selected.emit(item, value)


func _on_button_down() -> void:
	select_item()
