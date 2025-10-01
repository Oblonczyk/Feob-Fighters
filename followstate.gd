class_name EnemyFollowState
extends EnemyState

func enter() -> void:
	print("Enemy Following")
	play_walk_animation()

func play_walk_animation() -> void:
	if enemy.animation != null:
		if enemy.animation.has_animation("Walk"):
			enemy.animation.play("Walk")
			print("Animação Walk iniciada!")
		else:
			print("Animação 'Walk' não encontrada! Animações disponíveis: ", enemy.animation.get_animation_list())
	else:
		print("Animation reference is null in FollowState")
		if enemy.sprite != null and enemy.sprite.sprite_frames != null:
			if enemy.sprite.sprite_frames.has_animation("Walk"):
				enemy.sprite.play("Walk")
				print("Animação Walk iniciada no sprite!")

func process_physics(delta: float) -> EnemyState:
	var player_pos = enemy.player.global_position
	var enemy_pos = enemy.global_position
	var distance = enemy_pos.distance_to(player_pos)
	
	print("Following - Distance: ", distance)
	
	# VERIFICAÇÃO DE ATAQUE - deve retornar para o Attack State
	if distance < 77.0:  # Range de ataque
		print("Player in attack range! Transitioning to Attack State")
		return state_machine.attack_state  # ⬅️ ISSO que faz mudar de estado
	
	# Direção manual
	var dir = (player_pos - enemy_pos).normalized()
	enemy.velocity = dir * enemy.speed
	enemy.move_and_slide()

	enemy.sprite.flip_h = dir.x < 0

	# Retorna para idle se player estiver longe
	if distance > enemy.detection_radius:
		print("Player too far, returning to Idle")
		return state_machine.idle_state
	
	return null
