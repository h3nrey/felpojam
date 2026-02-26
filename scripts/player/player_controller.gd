extends Node2D

# SIGNALS
signal lives_changed(curr_lives)
signal queue_changed(curr_client_index: int, queue_size: int)
signal day_ended()
signal game_winned()
signal day_changed()
signal score_changed(correct_count: int)

# CONST
@export var total_lives = 3

# STATE
var curr_lives = 3
var correct_requests := 0
@export var curr_status = {
	"stamp": "",
	"service": "",
	"client_type": ""
}
var curr_day = null
var curr_day_index := 0
var client_queue := []
var selected_client = null
var curr_client_index = 0

# NODES
@onready var curr_state_text: Label = $"../CanvasLayer/curr_state"
@onready var curr_client_text: Label = $"../CanvasLayer/curr_client"
@onready var curr_client_sprite: Sprite2D = $"../Sprite2D"
@onready var game_over_panel: TextureRect = $"../CanvasLayer/gameOverPanel"
@onready var queue_container: HBoxContainer = $"../CanvasLayer/queue_container"


# Resources
@export var DAYS: Array[Day]
@export var client_card_scene: PackedScene

func _ready() -> void:
	if DAYS.is_empty():
		push_error("NO DAYS assigned!")
		return
	
	curr_day_index = 0
	curr_day = DAYS[0]
	setup_queue()
	setup_lives()
	connect_signals()
	

func connect_signals():
	SelectItem.on_item_selected.connect(on_item_selected)
	EventBus.on_client_wait_timeout.connect(on_client_timeout)
	EventBus.on_client_selected.connect(select_client)
	EventBus.on_document_submitted_correct.connect(on_document_correct)
	EventBus.on_document_submitted_wrong.connect(on_document_wrong)
	
func on_item_selected(item, value):
	curr_status[item] = value
	update_status_ui()
	

# Status
func clear_curr_status():
	curr_status = {
		"stamp": "",
		"service": "",
		"client_type": ""
	}
	update_status_ui()

func update_status_ui():
	curr_state_text.text =  "Type: " + curr_status["client_type"] + ", \n" + "Service: " + curr_status["service"]

# Document Checks
func _on_stamp_button_button_down() -> void:
	check_document()
	
func check_document():
	if selected_client == null:
		return
	
	var correct = \
		selected_client.service == curr_status["service"] and \
		selected_client.type == curr_status["client_type"]
	
	if not correct:
		handle_error()
		return
		
	handle_success(selected_client)

func handle_error():
	reduce_live()
	print("error")
	
func handle_success(client):
	remove_client(client)
	selected_client = null
	
	handle_next_client()

func handle_next_day():
	print("day index: ", curr_day_index)
	curr_day_index += 1
	print("day index: ", curr_day_index)
	
	if curr_day_index >= DAYS.size():
		game_won()
		return
	day_changed.emit()
	curr_day = DAYS[curr_day_index]
	setup_queue()
	print("day ended")
	
func end_day():
	day_ended.emit()
	
# clients
func setup_client():
	var curr_client = client_queue[curr_client_index]
	
	print(curr_client_text)
	curr_client_text.text = "Name: " + curr_client.name + ",\n" + "Type: " + curr_client.type + ", \n" + "Service: " + curr_client.service
	curr_client_sprite.texture = curr_client.sprite_texture
	
func remove_client(client):
	if not client_queue.has(client):
		return
	
	client_queue.erase(client)
	
	for card in queue_container.get_children():
		if card.client_reference == client:
			card.queue_free()
			break
	
	queue_changed.emit(client_queue.size())
	
#func make_client():
	#var client = Client.new()
	#client.name = "jorge"
	#client.sprite_texture = CLIENT_SPRITES.pick_random()
	#client.type = Types.CLIENT_TYPES.values().pick_random()
	#client.service = Types.SERVICES.values().pick_random()
	#return client
	
func select_client(client):
	if selected_client == client:
		selected_client = null
	selected_client = client

func on_document_correct(client, _document):
	correct_requests += 1
	score_changed.emit(correct_requests)
	remove_client(client)
	
	if selected_client == client:
		selected_client = null
	
	if client_queue.is_empty():
		end_day()

func on_document_wrong(_client, _document, reason):
	reduce_live()
	print("Document error: ", reason)	
	
func on_client_timeout(client):
	if not client_queue.has(client):
		return
	
	if selected_client == client:
		selected_client = null
	
	remove_client(client)
	reduce_live()
	
	if client_queue.is_empty():
		end_day()
	
	
func handle_next_client():
	curr_client_index += 1
	queue_changed.emit(curr_client_index, client_queue.size())
	clear_curr_status()
	
	if curr_client_index >= client_queue.size():
		end_day()
		return
	
	setup_client()

# Queue
func setup_queue():
	clear_queue_ui()
	client_queue = curr_day.clients.duplicate()
	correct_requests = 0
	score_changed.emit(correct_requests)
	
	for client in client_queue:
		spawn_card(client)
		
	queue_changed.emit(client_queue.size())
	
func spawn_card(client):
	var card = client_card_scene.instantiate()
	queue_container.add_child(card)
	
	card.client_reference = client
	
	card.initialize(client)
	
func clear_queue_ui():
	for child in queue_container.get_children():
		child.queue_free()
	
# Lives
func setup_lives():
	curr_lives = total_lives
	lives_changed.emit(curr_lives)
	
func reduce_live():
	curr_lives -= 1
	lives_changed.emit(curr_lives)
	
	if curr_lives <= 0:
		game_over_panel.visible = true

# End Game
func end_game():
	print("game ended")

# Game Won
func game_won():
	game_winned.emit()

	
func _on_next_day_button_button_down() -> void:
	handle_next_day()
