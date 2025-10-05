class_name PlayerKickState
extends PlayerState

var has_kicked: bool

func enter() -> void:
	print("Kick State")
	has_kicked = false
	
	# 🔥 MARCA QUE O PLAYER ESTÁ ATACANDO
	player.set_attacking(true)
	
	player.animation.play(kick_anim)

	# Espera a animação acabar
	await player.animation.animation_finished
	has_kicked = true

func exit() -> void:
	# 🔥 MARCA QUE O PLAYER PAROU DE ATACAR
	player.set_attacking(false)

func process_input(event: InputEvent) -> State:
	super.process_input(event)
	# Não troca de estado durante o chute, só quando terminar
	return null

func process_physics(delta: float) -> State:
	# Aplica gravidade para permitir chute no ar
	var input_direction = Input.get_axis("move_left", "move_right")
	
	# 🎯 ATUALIZA DIREÇÃO DO PLAYER
	if input_direction > 0:
		player.update_facing_direction(1)  # Direita
	elif input_direction < 0:
		player.update_facing_direction(-1)  # Esquerda
	player.velocity.y += gravity * delta
	player.move_and_slide()

	# Quando o chute termina → decide para onde ir
	if has_kicked:
		if player.is_on_floor():
			return idle_state
		else:
			return fall_state

	return null

func process_frame(delta: float) -> State:
	super.process_frame(delta)
	return null
