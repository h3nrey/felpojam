extends DraggableItem
class_name DocumentItem

var document: Document

func setup(doc: Document):
	document = doc
	
	item_type = ItemType.DOCUMENT
	
	update_visual()

func update_visual():
	var texture = DocumentDatabase.get_texture(document)
	
	if document.is_stamped:
		# aqui você pode aplicar overlay depois
		pass
	
	icon = texture
	item_value = document
	if sprite:
		sprite.texture = texture
		
func _get_drag_data(_pos):
	print("dragging pos", _pos)
	var data = super._get_drag_data(_pos)

	if get_parent() and get_parent().has_method("on_document_taken"):
		get_parent().on_document_taken(self)

	return data

func _can_drop_data(_pos, data):
	if typeof(data) != TYPE_DICTIONARY:
		return false
	if not data.has("type"):
		return false
	# Only accept stamps
	return data["type"] == DraggableItem.ItemType.STAMP

func _drop_data(_pos, data):
	var stamp_node = data.get("node")
	if stamp_node and stamp_node is StampItem:
		if stamp_node.is_ready():
			if stamp_node.service_type == document.service_type:
				stamp_node.use_stamp()
				document.is_stamped = true
				update_visual()
				print("Document stamped successfully!")
				EventBus.on_document_stamped.emit(document)
			else:
				print("Wrong stamp type! Document needs: ", document.service_type, " but stamp is: ", stamp_node.service_type)
		else:
			print("Stamp is not ready!")
