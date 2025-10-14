class_name EnemyDefState
extends EnemyState

var block_timer: float = 0.0

func enter() -> void:
	print("🛡️🛡️🛡️ Enemy Def State - ENTER")
	enemy.velocity = Vector2.ZERO
	enemy.start_block()
	block_timer = enemy.block_duration
	
	# 🔥 DEBUG ESPECÍFICO DA ANIMAÇÃO
	print("🎬 INICIANDO ANIMAÇÃO DEF...")
	
	if enemy.animation:
		print("   ✅ AnimationPlayer encontrado")
		print("   📋 Animação atual antes: ", enemy.animation.current_animation)
		print("   ▶️ Tentando tocar 'Def'...")
		
		if enemy.animation.has_animation("Def"):
			print("   ✅ Animação 'Def' existe")
			enemy.animation.play("Def")
			print("   🎬 Animação iniciada: ", enemy.animation.current_animation)
			print("   ⏱️ Está tocando?: ", enemy.animation.is_playing())
		else:
			print("   ❌ Animação 'Def' NÃO existe")
			
	elif enemy.sprite and enemy.sprite.sprite_frames:
		print("   ✅ Sprite com SpriteFrames encontrado")
		print("   ▶️ Tentando tocar 'Def' no sprite...")
		
		if enemy.sprite.sprite_frames.has_animation("Def"):
			print("   ✅ Animação 'Def' existe no sprite")
			enemy.sprite.play("Def")
			print("   🎬 Animação do sprite: ", enemy.sprite.animation)
		else:
			print("   ❌ Animação 'Def' NÃO existe no sprite")
	else:
		print("   ❌ Nenhum sistema de animação encontrado")

func exit() -> void:
	print("🛡️ Enemy Def State - EXIT")
	enemy.end_block()
	play_idle_animation()

func play_idle_animation() -> void:
	if enemy.animation and enemy.animation.has_animation("Idle"):
		enemy.animation.play("Idle")
		print("🎬 Voltando para Idle")
	elif enemy.sprite and enemy.sprite.sprite_frames and enemy.sprite.sprite_frames.has_animation("Idle"):
		enemy.sprite.play("Idle")
		print("🎬 Voltando para Idle no sprite")

func process_physics(delta: float) -> EnemyState:
	block_timer -= delta
	
	# 🔥 DEBUG DA ANIMAÇÃO DURANTE O ESTADO
	if int(block_timer * 10) % 10 == 0:  # Log a cada segundo
		if enemy.animation:
			print("⏱️ Animação atual: ", enemy.animation.current_animation, " | Tocando: ", enemy.animation.is_playing())
		elif enemy.sprite:
			print("⏱️ Sprite animation: ", enemy.sprite.animation)
	
	# Verifica se deve parar de bloquear
	if block_timer <= 0:
		print("🛡️ Block duration ended")
		return state_machine.follow_state
	
	# Verifica se o player parou de atacar
	if not enemy.is_player_attacking_nearby():
		print("🛡️ Player stopped attacking, ending block")
		return state_machine.follow_state
	
	# Mantém bloqueando enquanto o player estiver atacando
	enemy.velocity = Vector2.ZERO
	
	return null
