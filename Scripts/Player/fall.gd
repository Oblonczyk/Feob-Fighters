class_name PlayerFallState
extends PlayerState

const AIR_SPEED: float = 150.0

func enter() -> void:
	print("Fall State")
	super.enter()
	player.animation.play(fall_anim, -1, 1)
	
func exit() -> void:
	super.exit()
	player.velocity.x = 0.0

func process_input(event: InputEvent) -> State:
	super.process_input(event)
	# Normalmente, no estado de queda, não tratamos input especial,
	# apenas o movimento horizontal
	return null

func process_physics(delta: float) -> State:
	var input_direction = Input.get_axis("move_left", "move_right")
	
	# 🎯 ATUALIZA DIREÇÃO DO PLAYER
	if input_direction > 0:
		player.update_facing_direction(1)  # Direita
	elif input_direction < 0:
		player.update_facing_direction(-1)  # Esquerda
	do_move(get_move_dir())
	
	# Aplica a gravidade
	player.velocity.y += gravity * delta
	player.move_and_slide()

	# Transições de estado
	if player.is_on_floor():
		return idle_state
	elif Input.is_action_just_pressed(jump_key) and player.is_on_floor():
		return jump_state
	
	return null
	
func get_move_dir() -> float:
	return Input.get_axis(left_key, right_key)

func do_move(move_dir: float) -> void:
	player.velocity.x = move_dir * AIR_SPEED
