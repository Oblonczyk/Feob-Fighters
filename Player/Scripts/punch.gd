class_name PlayerPunchState
extends PlayerState

var has_attacked: bool

@onready var hitbox: Area2D = $HitBox
	
func enter() -> void:
	print("Punch State")
	has_attacked = false
	
	# Corrige flip da hitbox sem erro de sintaxe
	hitbox.position.x = abs(hitbox.position.x) * (-1 if sprite_flipped else 1)

	# Toca animação de soco
	player.animation.play(punch_anim)
	
	# Conecta o fim da animação de forma segura
	if not player.animation.is_connected("animation_finished", Callable(self, "_on_punch_finished")):
		player.animation.animation_finished.connect(_on_punch_finished)

func _on_punch_finished(_anim: String) -> void:
	has_attacked = true

func process_input(event: InputEvent) -> State:
	super.process_input(event)
	if has_attacked and event.is_action_pressed(movement_key):
		determine_sprite_flipped(event.as_text())
		return walk_state
	elif has_attacked and event.is_action_pressed(jump_key):
		return jump_state
	return null

func process_physics(delta: float) -> State:
	# Aplica gravidade mesmo durante o soco no ar
	player.velocity.y += gravity * delta
	player.move_and_slide()
	
	# Quando terminar o soco, se não estiver no chão → cai, se estiver → volta ao idle
	if has_attacked:
		if player.is_on_floor():
			return idle_state
		else:
			return fall_state
	
	return null

func process_frame(delta: float) -> State:
	super.process_frame(delta)
	return null

func add_game_juice() -> void:
	if camera:
		camera.zoom = Vector2(1.15, 1.15)
