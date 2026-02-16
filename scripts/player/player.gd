extends CharacterBody2D


@export var SPEED = 300.0


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()

	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2(move_toward(velocity.x, 0, SPEED),  move_toward(velocity.y, 0, SPEED))

	move_and_slide()
