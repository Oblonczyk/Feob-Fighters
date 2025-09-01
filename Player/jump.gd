class_name PlayerJumpState
extends PlayerState

const AIR_SPEED: float = 75.0
const JUMP_FORCE: float = 350.0 # Ajustado para dar impulso real

func enter() -> void:
	print("Jump State")
	super.enter()
	player.velocity.y = -JUMP_FORCE
	player.animation.play(jump_anim, -1, 2)
	
func exit() -> void:
	super.exit()
	player.velocity.x = 0.0
	
func process_input(event: InputEvent) -> State:
	super.process_input(event)
	
	# Se soltar o botão de pulo antes do pico, corta a altura (short hop)
	if event.is_action_released(jump_key) and player.velocity.y < 0:
		player.velocity.y *= 0.5

	# Se apertar o soco no ar → troca para o estado de Punch
	if event.is_action_pressed(punch_key):
		return punch_state

	# Se apertar o chute no ar → troca para o estado de Kick
	if event.is_action_pressed(kick_key):
		return kick_state
		
	return null


func process_physics(delta: float) -> State:
	do_move(get_move_dir())
	
	# Aplica a gravidade
	player.velocity.y += gravity * delta
	player.move_and_slide()
	
	# Transições de estado
	# Se encostar no chão, volta para o estado Idle
	if player.is_on_floor():
		return idle_state
	# Se a velocidade for positiva (descendo), troca para o estado Fall
	elif player.velocity.y > 0:
		return fall_state
		
	return null
	
func get_move_dir() -> float:
	return Input.get_axis(left_key, right_key)
	
func do_move(move_dir: float) -> void:
	player.velocity.x = move_dir * AIR_SPEED
