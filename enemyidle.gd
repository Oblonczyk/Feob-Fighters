class_name EnemyIdleState
extends EnemyState

func enter() -> void:
	print("Enemy Idle")
	enemy.velocity = Vector2.ZERO
	if enemy.animation != null:
		if enemy.animation.has_animation("Idle"):
			enemy.animation.play("Idle")
			print("Animação Idle iniciada!")
		else:
			print("Animação 'Idle' não encontrada! Animações disponíveis: ", enemy.animation.get_animation_list())
	else:
		print("Animation reference is null in IdleState")
		if enemy.sprite != null and enemy.sprite.sprite_frames != null:
			if enemy.sprite.sprite_frames.has_animation("Idle"):
				enemy.sprite.play("Idle")
				print("Animação Idle iniciada no sprite!")

func process_physics(delta: float) -> EnemyState:
	if not is_instance_valid(enemy) or not is_instance_valid(enemy.player):
		print("ERROR: Enemy or Player is invalid!")
		return null
	
	# CALCULE MANUALMENTE a distância
	var player_pos = enemy.player.global_position
	var enemy_pos = enemy.global_position
	var distance = enemy_pos.distance_to(player_pos)
	
	print("Distance to player: ", distance, " | Detection radius: ", enemy.detection_radius)
	
	if distance <= enemy.detection_radius:
		print("Changing to Follow State!")
		return state_machine.follow_state
	
	return null

func process_frame(delta: float) -> EnemyState:
	return null
