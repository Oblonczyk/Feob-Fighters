class_name EnemyIdleState
extends EnemyState

func enter() -> void:
	print("Enemy Idle")
	enemy.velocity = Vector2.ZERO
	
	# ANIMAÇÃO
	if enemy.animation and enemy.animation.has_animation("Idle"):
		enemy.animation.play("Idle")
	elif enemy.sprite and enemy.sprite.sprite_frames and enemy.sprite.sprite_frames.has_animation("Idle"):
		enemy.sprite.play("Idle")

func process_physics(delta: float) -> EnemyState:
	if not is_instance_valid(enemy) or not is_instance_valid(enemy.player):
		return null
	
	# 🔥 SEMPRE MUDA PARA FOLLOW - SEM VERIFICAÇÃO DE DISTÂNCIA
	print("Changing to Follow State!")
	return state_machine.follow_state

func process_frame(delta: float) -> EnemyState:
	# 🔥 TAMBÉM NO FRAME PARA MAIS RAPIDEZ
	if not is_instance_valid(enemy) or not is_instance_valid(enemy.player):
		return null
	
	return state_machine.follow_state
