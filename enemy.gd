extends CharacterBody2D
class_name Enemy

@export var detection_radius: float = 150.0
@export var speed: float = 50.0
@export var player_path: NodePath

@onready var state_machine: EnemyStateMachine = $"State Machine"
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: AnimatedSprite2D = $Sprite

var player: Player

func _ready() -> void:
	print("Enemy _ready called")
	
	# DEBUG COMPLETO DAS ANIMAÇÕES
	print("=== DEBUG COMPLETO DE ANIMAÇÕES ===")
	
	# Verifica o nó Animation
	print("Animation node: ", $Animation if has_node("Animation") else "NÃO ENCONTRADO")
	print("Variável animation: ", animation)
	print("É válida? ", is_instance_valid(animation))
	
	if animation:
		print("Tipo da variável animation: ", animation.get_class())
		print("Animações disponíveis no AnimationPlayer:")
		var anim_list = animation.get_animation_list()
		if anim_list.size() > 0:
			for anim in anim_list:
				print("  - ", anim)
		else:
			print("  NENHUMA ANIMAÇÃO ENCONTRADA!")
	else:
		print("ERRO: AnimationPlayer não está carregado!")
	
	print("---")
	
	# Verifica o nó Sprite
	print("AnimatedSprite2D node: ", $Sprite if has_node("Sprite") else "NÃO ENCONTRADO")
	print("Variável sprite: ", sprite)
	print("É válida? ", is_instance_valid(sprite))
	
	if sprite:
		print("Tipo da variável sprite: ", sprite.get_class())
		if sprite.sprite_frames:
			print("SpriteFrames encontrado!")
			print("Animações disponíveis no Sprite:")
			var sprite_anims = sprite.sprite_frames.get_animation_names()
			if sprite_anims.size() > 0:
				for anim in sprite_anims:
					print("  - ", anim)
			else:
				print("  NENHUMA ANIMAÇÃO ENCONTRADA!")
		else:
			print("ERRO: SpriteFrames não encontrado no Sprite!")
	else:
		print("ERRO: AnimatedSprite2D não está carregado!")
	
	print("---")
	
	# Verifica animações específicas de ataque
	print("VERIFICAÇÃO DE ANIMAÇÕES DE ATAQUE:")
	if animation:
		print("Tem animação 'punch'? ", animation.has_animation("punch"))
		print("Tem animação 'kick'? ", animation.has_animation("kick"))
		print("Tem animação 'attack'? ", animation.has_animation("attack"))
	
	if sprite and sprite.sprite_frames:
		print("Sprite tem animação 'punch'? ", sprite.sprite_frames.has_animation("punch"))
		print("Sprite tem animação 'kick'? ", sprite.sprite_frames.has_animation("kick"))
		print("Sprite tem animação 'attack'? ", sprite.sprite_frames.has_animation("attack"))
	
	print("==========================")
	
	# Pega o player a partir do NodePath exportado
	if player_path.is_empty():
		print("ERROR: Player path is empty!")
		return
	
	player = get_node(player_path)
	
	if not is_instance_valid(player):
		print("ERROR: Player is not valid!")
		return
	
	print("Player found: ", player.name)
	
	# Aguarda até o próximo frame para garantir que todos os nós estejam prontos
	await get_tree().process_frame
	state_machine.init(self)
	print("StateMachine initialized successfully")

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)

func distance_to_player() -> float:
	if not is_instance_valid(player):
		return INF
	return global_position.distance_to(player.global_position)

func direction_to_player() -> Vector2:
	if not is_instance_valid(player):
		return Vector2.ZERO
	return (player.global_position - global_position).normalized()

# Sistema de hitbox para ataques
func create_hitbox(damage: int, force: float, duration: float) -> void:
	# Cria uma área de hit temporária
	var hitbox = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	
	shape.radius = 20.0
	collision.shape = shape
	hitbox.add_child(collision)
	
	# Configura a hitbox baseada na direção do sprite
	hitbox.position = Vector2(30 * (-1 if sprite.flip_h else 1), 0)
	hitbox.collision_mask = 1  # Ajuste para a layer do player
	
	add_child(hitbox)
	
	# Conexão temporária para detectar hit
	if not hitbox.body_entered.is_connected(_on_hitbox_body_entered):
		hitbox.body_entered.connect(_on_hitbox_body_entered.bind(damage, force))
	
	# Remove após duração
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(hitbox):
		hitbox.queue_free()

func _on_hitbox_body_entered(body: Node, damage: int, force: float) -> void:
	if body is Player:
		print("Hit player! Damage: ", damage)
		# Aplica dano e knockback no player
		var direction = (body.global_position - global_position).normalized()
		if body.has_method("take_damage"):
			body.take_damage(damage, direction * force)

# Função opcional para debug visual do raio de detecção
func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, detection_radius, Color(1, 0, 0, 0.1))
