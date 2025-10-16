class_name PlayerIdleState
extends PlayerState

func enter() -> void:
	print("Idle State")
	super.enter()
	player.animation.play(idle_anim)
	player.velocity.x = 0.0

func exit() -> void:
	super.exit()

func process_input(event: InputEvent) -> State:
	# Se apertar chute → entra no estado de chute
	if Input.is_action_just_pressed(kick_key):
		return kick_state

	# Se apertar soco → entra no estado de soco
	if Input.is_action_just_pressed(punch_key):
		return punch_state

	# Se pular → vai para jump_state
	if Input.is_action_just_pressed(jump_key) and player.is_on_floor():
		return jump_state

	# Se andar → vai para walk_state
	if Input.is_action_pressed(movement_key) or Input.is_action_pressed(left_key) or Input.is_action_pressed(right_key):
		return walk_state
		
	return null

func process_physics(delta: float) -> State:
	# Aplica a gravidade
	player.velocity.y += gravity * delta
	player.move_and_slide()
	
	# Se o jogador não estiver mais no chão → vai para o estado de Queda
	if not player.is_on_floor():
		return fall_state
		
	return null
