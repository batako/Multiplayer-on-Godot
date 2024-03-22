extends CharacterBody2D


@export var sync_position := Vector2.ZERO

const SPEED = 300.0


func _physics_process(delta):
	if not is_local_authority():
		position = sync_position
		return
	
	if Input.is_action_pressed("ui_left"):
		position.x -= delta * SPEED
	if Input.is_action_pressed("ui_right"):
		position.x += delta * SPEED
	if Input.is_action_pressed("ui_up"):
		position.y -= delta * SPEED
	if Input.is_action_pressed("ui_down"):
		position.y += delta * SPEED
	
	rpc_id(1, StringName("push_to_server"), position)


func is_local_authority() -> bool:
	return name == str(multiplayer.get_unique_id())


@rpc("any_peer", "unreliable_ordered")
func push_to_server(_sync_pos: Vector2):
	if not multiplayer.is_server():
		return
	if name != str(multiplayer.get_remote_sender_id()):
		print("someone being naughty!", multiplayer.get_remote_sender_id(), ' tried to update ', name)
		return
	sync_position = _sync_pos
	
