extends Control
class_name DragableSlot

signal item_dropped(item_type: DraggableItem.ItemType, item_value: Variant)

@export var accepted_type: DraggableItem.ItemType

func _can_drop_data(_pos, data):
	if typeof(data) != TYPE_DICTIONARY:
		return false
	
	if not data.has("type"):
		return false
	
	return data.type == accepted_type

func _drop_data(_pos, data):
	print("Data dropped: ", data)
	if data.has("node") and data["node"] is Node:
		print("Dropping node: ", data["node"])
		var node = data["node"]
		if node.get_parent():
			node.get_parent().remove_child(node)
		add_child(node)
		if node is Control:
			node.position = Vector2.ZERO
	item_dropped.emit(data.type, data.value)
