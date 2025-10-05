extends Area2D

@export var speed: float = 400.0
@export var lifetime: float = 3.0
@export var damage: int = 10
var direction: int = 1
var time_alive: float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# DEBUG - Verificar se está chegando aqui
	print("🎯 Special criado! Direção recebida: ", direction)
	print("📍 Posição inicial do special: ", position)
	
	# Conecta sinal do AnimatedSprite2D
	anim.animation_finished.connect(self._on_explode_finished)
	
	# 🎯 CORREÇÃO: Garantir que o sprite está correto para ambas as direções
	if direction == -1:
		anim.flip_h = true
		print("🔄 Sprite invertido para ESQUERDA")
	else:
		anim.flip_h = false  # Garante que está normal para direita
		print("🔄 Sprite normal para DIREITA")
	
	# Toca animação de voo
	if anim.sprite_frames.has_animation("fly"):
		anim.play("fly")

func _process(delta: float) -> void:
	# 🎯 DEBUG DETALHADO - Antes do movimento
	var pos_antes = position.x
	print("🎯 PROJÉTIL - Direction: ", direction, " | Speed: ", speed, " | Pos X antes: ", pos_antes)
	
	# Movimento horizontal baseado na direção
	position.x += speed * direction * delta
	
	# 🎯 DEBUG DETALHADO - Após movimento
	var pos_depois = position.x
	var movimento = pos_depois - pos_antes
	print("🎯 PROJÉTIL - Pos X depois: ", pos_depois, " | Movimento: ", movimento, " | Deveria ir para: ", "DIREITA" if movimento > 0 else "ESQUERDA")

	# Contador de vida
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		if area.has_method("take_damage"):
			area.take_damage(damage)

		# Toca animação de explosão
		if anim.sprite_frames.has_animation("explode"):
			anim.play("explode")
		else:
			queue_free()
	else:
		queue_free()

func _on_explode_finished(anim_name: String) -> void:
	if anim_name == "explode":
		queue_free()
