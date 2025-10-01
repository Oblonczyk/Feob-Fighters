class_name PlayerWalkState
extends PlayerState

const SPEED: float = 75.0

func enter() -> void:
	print("Walk State")
	super()
	player.animation.play(walk_anim)

func exit() -> void:
	super()
	player.velocity.x = 0.0

func process_physics(delta: float) -> State:
	var dir := 0
	if Input.is_action_pressed(left_key):
		dir -= 1
	if Input.is_action_pressed(right_key):
		dir += 1

	player.velocity.x = dir * SPEED

	# Atualiza flip do sprite
	determine_sprite_flipped_from_input()

	# Se parou de se mover, troca para Idle
	if dir == 0:
		return idle_state

	# Se apertar soco durante o movimento, troca para Punch
	if Input.is_action_just_pressed(punch_key):
		return punch_state

	# Se apertar chute durante o movimento, troca para Kick
	if Input.is_action_just_pressed(kick_key):
		return kick_state

	# Se apertar pulo enquanto anda e estiver no chão, troca para Jump
	if Input.is_action_just_pressed(jump_key) and player.is_on_floor():
		return jump_state

	# Aplica gravidade e move
	return super(delta)

func process_frame(delta: float) -> State:
	# Verifica se soltou as teclas e vai para Idle
	if not Input.is_action_pressed(left_key) and not Input.is_action_pressed(right_key):
		return idle_state

	# Também verifica ataques aqui para maior responsividade
	if Input.is_action_just_pressed(punch_key):
		return punch_state

	if Input.is_action_just_pressed(kick_key):
		return kick_state

	# Também pode checar pulo no frame para maior responsividade
	if Input.is_action_just_pressed(jump_key) and player.is_on_floor():
		return jump_state

	return null

func determine_sprite_flipped_from_input() -> void:
	if Input.is_action_pressed(left_key):
		sprite_flipped = false
	elif Input.is_action_pressed(right_key):
		sprite_flipped = true
	player.sprite.flip_h = sprite_flipped
