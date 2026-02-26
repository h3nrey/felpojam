extends Control

signal document_printed(document: Document)

var generated_document: Document = null
var printed_item: DocumentItem = null

var is_printing := false
var is_finished := false
var is_dragging_document := false

var current_paper: Types.PaperType = -1
var current_service: Types.ServiceType = -1

@export var print_time := 3.0
var elapsed_time := 0.0
@export var document_scene: PackedScene

# Nodes
@onready var panel: Panel = $Panel
@onready var paper_icon: TextureRect = $Panel/IconsContainer/PaperPanel/icon
@onready var service_icon: TextureRect = $Panel/IconsContainer/ServicePanel/icon
@onready var progress_bar: TextureProgressBar = $Panel/ProgressBar
@onready var completed_icon: TextureRect = $Panel/markedIcon
@onready var icons_container: HBoxContainer = $Panel/IconsContainer


func _ready():
	panel.visible = false
	progress_bar.visible = false
	completed_icon.visible = false
	icons_container.visible = true


func _process(delta):
	if not is_printing:
		return
	
	elapsed_time += delta
	progress_bar.value = print_time - elapsed_time
	
	if elapsed_time >= print_time:
		finish_printing()


# =============================
# DRAG & DROP
# =============================

func _can_drop_data(_pos, data):
	if typeof(data) != TYPE_DICTIONARY:
		return false
	if not data.has("type"):
		return false
	return not is_printing and not is_finished


func _drop_data(_pos, data):
	panel.visible = true
	
	match data["type"]:
		DraggableItem.ItemType.PAPER:
			current_paper = data["value"]
			paper_icon.texture = data["icon"]
		
		DraggableItem.ItemType.SERVICE:
			current_service = data["value"]
			service_icon.texture = data["icon"]
	
	check_start_print()
	update_visual_state()


# =============================
# PRINT FLOW
# =============================

func check_start_print():
	if current_paper != -1 and current_service != -1:
		start_printing()


func start_printing():
	is_printing = true
	is_finished = false
	
	elapsed_time = 0.0
	
	progress_bar.max_value = print_time
	progress_bar.value = print_time
	
	update_visual_state()


func finish_printing():
	is_printing = false
	is_finished = true
	
	create_document()
	update_visual_state()


func create_document():
	generated_document = Document.new(current_paper, current_service)

	completed_icon.texture = DocumentDatabase.get_texture(generated_document)

	if document_scene:
		printed_item = document_scene.instantiate()
		printed_item.setup(generated_document)
		printed_item.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(printed_item)

# =============================
# Drag TO COLLECT
# =============================

func collect_document():
	print("collecting not ready")
	if not printed_item:
		return
		
	print("collecting readed")
	
	# Move o mesmo item para fora da impressora
	remove_child(printed_item)
	get_parent().add_child(printed_item)
	
	document_printed.emit(generated_document)
	reset_printer()
	
func _get_drag_data(_pos: Vector2):
	if not is_finished or generated_document == null:
		return null
		
	var texture = DocumentDatabase.get_texture(generated_document)
	
	var container = Control.new()
	container.custom_minimum_size = Vector2(48, 48)
	container.size = Vector2(48, 48)
	
	var preview = TextureRect.new()
	preview.texture = texture
	preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	container.add_child(preview)
	
	if has_node("/root/DragLayer"):
		get_node("/root/DragLayer").set_preview(container)
	else:
		set_drag_preview(container)
	
	var data = {
		"type": DraggableItem.ItemType.DOCUMENT,
		"value": generated_document,
		"icon": texture,
		"node": printed_item
	}
	
	is_dragging_document = true
	return data

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		if has_node("/root/DragLayer"):
			get_node("/root/DragLayer").clear_preview()
		if is_dragging_document:
			is_dragging_document = false
			if is_drag_successful():
				if printed_item:
					on_document_taken(printed_item)
				else:
					document_printed.emit(generated_document)
					reset_printer()

func on_document_taken(doc_item: DocumentItem):

	print("document taken", doc_item)

	printed_item = null
	generated_document = null
	
	is_finished = false
	panel.visible = false
	
	update_visual_state()


# =============================
# RESET
# =============================

func reset_printer():
	current_paper = -1
	current_service = -1
	
	paper_icon.texture = null
	service_icon.texture = null
	
	generated_document = null
	printed_item = null
	completed_icon.texture = null
	
	is_printing = false
	is_finished = false
	
	panel.visible = false
	update_visual_state()


# =============================
# UI STATE
# =============================

func update_visual_state():
	icons_container.visible = not is_printing and not is_finished
	progress_bar.visible = is_printing
	completed_icon.visible = is_finished
