class_name EnemyJumpState
extends EnemyState

const AIR_SPEED: float = 75.0  # MESMO VALOR DO PLAYER
const JUMP_FORCE: float = 350.0  # MESMO VALOR DO PLAYER
const gravity: float = 980.0  # MESMO VALOR DO PLAYER (calculado baseado no seu código)

var has_jumped: bool = false

func enter() -> void:
	print("Entering Jump State")
	has_jumped = false
	# Inicia o pulo com a mesma força do player
	enemy.velocity.y = -JUMP_FORCE
	has_jumped = true
	
	# Toca animação de pulo
	if enemy.animation and enemy.animation.has_animation("jump"):
		enemy.animation.play("jump", -1, 2)  # MESMO PARÂMETRO DO PLAYER
	elif enemy.sprite and enemy.sprite.sprite_frames and enemy.sprite.sprite_frames.has_animation("jump"):
		enemy.sprite.play("jump")

func process_physics(delta: float) -> EnemyState:
	if not enemy:
		return null
	
	# Movimento horizontal no ar (mesmo do player)
	var move_dir = get_move_direction()
	do_move(move_dir)
	
	# Aplica gravidade (mesmo cálculo do player)
	enemy.velocity.y += gravity * delta
	
	# Move o inimigo
	enemy.move_and_slide()
	
	# Verifica transições de estado (mesma lógica do player)
	if enemy.is_on_floor():
		# 🔥 CORREÇÃO: SEM DETECTION_RADIUS - SEMPRE VOLTA PARA FOLLOW
		print("Landed from jump! Returning to Follow State")
		return state_machine.follow_state
	elif enemy.velocity.y > 0:  # MESMA CONDIÇÃO DO PLAYER
		# Começou a cair, muda para Fall State
		return state_machine.fall_state
	
	return null

# Funções similares às do player
func get_move_direction() -> float:
	if not is_instance_valid(enemy.player):
		return 0.0
	
	var direction = enemy.direction_to_player()
	return direction.x

func do_move(move_dir: float) -> void:
	enemy.velocity.x = move_dir * AIR_SPEED
	# Flip do sprite baseado na direção
	if move_dir != 0:
		enemy.sprite.flip_h = move_dir < 0

func exit() -> void:
	print("Exiting Jump State")
