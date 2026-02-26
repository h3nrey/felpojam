extends Control

signal document_printed(document: Document)

var generated_document: Document = null
var printed_item: DocumentItem = null

var is_printing := false
var is_finished := false
var is_dragging_document := false

var current_paper: Types.PaperType = -1 as Types.PaperType
var current_service: Types.ServiceType = -1 as Types.ServiceType

@export var print_time := 3.0
var elapsed_time := 0.0
@export var document_scene: PackedScene

# Style resources (loaded from scene)
var style_slot_default: StyleBoxFlat
var style_slot_filled: StyleBoxFlat

# Nodes
@onready var progress_bar: ProgressBar = $ProgressBar

@onready var slots_container: HBoxContainer = $SlotsContainer
@onready var paper_slot: Panel = $SlotsContainer/PaperSlot
@onready var paper_plus: Label = $SlotsContainer/PaperSlot/PlusLabel
@onready var paper_icon: TextureRect = $SlotsContainer/PaperSlot/Icon
@onready var service_slot: Panel = $SlotsContainer/ServiceSlot
@onready var service_plus: Label = $SlotsContainer/ServiceSlot/PlusLabel
@onready var service_icon: TextureRect = $SlotsContainer/ServiceSlot/Icon

@onready var document_slot: Control = $DocumentSlot


func _ready():
	# Store style references
	style_slot_default = paper_slot.get_theme_stylebox("panel").duplicate()
	style_slot_filled = style_slot_default.duplicate()
	style_slot_filled.bg_color = Color(0.3, 0.6, 0.3, 0.9)
	
	progress_bar.visible = false
	progress_bar.max_value = print_time
	
	update_visual_state()


func _process(delta):
	if not is_printing:
		return
	
	elapsed_time += delta
	progress_bar.value = elapsed_time
	
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
	match data["type"]:
		DraggableItem.ItemType.PAPER:
			current_paper = data["value"]
			paper_icon.texture = data["icon"]
			paper_icon.visible = true
			paper_plus.visible = false
		
		DraggableItem.ItemType.SERVICE:
			current_service = data["value"]
			service_icon.texture = data["icon"]
			service_icon.visible = true
			service_plus.visible = false
	
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
	progress_bar.value = 0.0
	progress_bar.max_value = print_time
	
	update_visual_state()


func finish_printing():
	is_printing = false
	is_finished = true
	
	create_document()
	update_visual_state()


func create_document():
	generated_document = Document.new(current_paper, current_service)

	if document_scene:
		printed_item = document_scene.instantiate()
		printed_item.setup(generated_document)
		printed_item.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		document_slot.add_child(printed_item)


# =============================
# Drag TO COLLECT
# =============================

func collect_document():
	if not printed_item:
		return
	
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


func on_document_taken(_doc_item: DocumentItem):
	printed_item = null
	generated_document = null
	is_finished = false
	
	reset_printer()


# =============================
# RESET
# =============================

func reset_printer():
	current_paper = -1 as Types.PaperType
	current_service = -1 as Types.ServiceType
	
	paper_icon.texture = null
	paper_icon.visible = false
	paper_plus.visible = true
	
	service_icon.texture = null
	service_icon.visible = false
	service_plus.visible = true
	
	generated_document = null
	printed_item = null
	
	is_printing = false
	is_finished = false
	
	update_visual_state()


# =============================
# UI STATE
# =============================

func update_visual_state():
	var has_paper = current_paper != -1
	var has_service = current_service != -1
	
	# Slots container - always visible except when finished
	slots_container.visible = not is_finished
	
	# Update slot styles and visibility based on filled state
	if has_paper:
		paper_slot.add_theme_stylebox_override("panel", style_slot_filled)
		paper_plus.visible = false
		paper_icon.visible = true
	else:
		paper_slot.add_theme_stylebox_override("panel", style_slot_default)
		paper_plus.visible = true
		paper_icon.visible = false
	
	if has_service:
		service_slot.add_theme_stylebox_override("panel", style_slot_filled)
		service_plus.visible = false
		service_icon.visible = true
	else:
		service_slot.add_theme_stylebox_override("panel", style_slot_default)
		service_plus.visible = true
		service_icon.visible = false
	
	# Progress bar - only visible during printing
	progress_bar.visible = is_printing
	
	# Document slot - visible when finished
	document_slot.visible = is_finished
