extends VBoxContainer

@export var debug = false

var initialized = false
var running = false
var client_reference = null
var patience_duration := 5
var elapsed_time := 0.0
@export var type_icons: Dictionary[String, Texture2D] = {}
@export var service_icons: Dictionary[String, Texture2D] = {}
@onready var progress_bar: TextureProgressBar = $progress_bar
@onready var type_icon: TextureRect = $icons_container/icon_container/icon
@onready var service_icon: TextureRect = $icons_container/icon_container2/icon

# Mapping for validation
var paper_type_map = {
	"hell": Types.PaperType.HELL,
	"paradise": Types.PaperType.PARADISE
}
var service_type_map = {
	"death": Types.ServiceType.DEATH,
	"marriage": Types.ServiceType.MARRIAGE,
	"inheritance": Types.ServiceType.INHERITANCE
}

func _ready() -> void:
	if debug:
		setup_card(patience_duration)
	
	if initialized:
		setup_card(patience_duration, client_reference.type, client_reference.service)

func _process(delta: float) -> void:
	elapsed_time += delta
	decrease_value(elapsed_time)
	pass
	
func initialize(client):
	client_reference = client
	patience_duration = client.patience_duration
	initialized = true
	
	
func decrease_value(elapsed_time):
	if not running:
		return
		
	if elapsed_time >= patience_duration:
		running = false
		EventBus.on_client_wait_timeout.emit(client_reference)
		return
	progress_bar.value = patience_duration - elapsed_time
	
func setup_card(duration: int, type = null, service = null):
	patience_duration = duration
	progress_bar.max_value = duration
	progress_bar.value = duration
	
	print("reference: ", type)
	print("reference service: ", service)
	if type && service:
		type_icon.texture = type_icons.get(type)
		service_icon.texture = service_icons.get(service)
	running = true

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			EventBus.sfx_click.emit()
			EventBus.on_client_selected.emit(client_reference)
			print("selecting client", client_reference.type)

func _can_drop_data(_pos, data):
	if typeof(data) != TYPE_DICTIONARY:
		return false
	if not data.has("type"):
		return false
	# Only accept documents
	return data["type"] == DraggableItem.ItemType.DOCUMENT

func _drop_data(_pos, data):
	var document_node = data.get("node")
	if not document_node or not document_node is DocumentItem:
		return
	
	var document: Document = document_node.document
	
	# Check if document is stamped
	if not document.is_stamped:
		EventBus.on_document_submitted_wrong.emit(client_reference, document, "not_stamped")
		EventBus.sfx_drop_fail.emit()
		print("Document is not stamped!")
		return
	
	# Get expected types from client
	var expected_paper = paper_type_map.get(client_reference.type)
	var expected_service = service_type_map.get(client_reference.service)
	
	# Validate paper type
	if document.paper_type != expected_paper:
		EventBus.on_document_submitted_wrong.emit(client_reference, document, "wrong_paper")
		EventBus.sfx_drop_fail.emit()
		print("Wrong paper type! Expected: ", client_reference.type, " Got: ", document.paper_type)
		return
	
	# Validate service type
	if document.service_type != expected_service:
		EventBus.on_document_submitted_wrong.emit(client_reference, document, "wrong_service")
		EventBus.sfx_drop_fail.emit()
		print("Wrong service type! Expected: ", client_reference.service, " Got: ", document.service_type)
		return
	
	# All correct!
	EventBus.on_document_submitted_correct.emit(client_reference, document)
	EventBus.sfx_drop_success.emit()
	print("Document submitted correctly!")
	
	# Remove the document node
	document_node.queue_free()
