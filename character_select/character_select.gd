extends Control

# Referências aos nós
@onready var left_player: AnimatedSprite2D = $HBoxContainer/LeftPlayer
@onready var right_player: AnimatedSprite2D = $HBoxContainer/RightPlayer
@onready var avatars: Array[TextureRect] = [$AvatarsContainer/Avatar1, $AvatarsContainer/Avatar2, $AvatarsContainer/Avatar3, $AvatarsContainer/Avatar4]
@onready var button_retornar: TextureButton = $BottomMenu/ButtonRetornar

# Variáveis para seleção
var selected_left: int = 0
var selected_right: int = 0
var character_textures: Array[Texture2D] = []

func _ready():
	# Verifica se os nós existem antes de usá-los
	if not left_player or not right_player:
		push_warning("Nós AnimatedSprite2D (LeftPlayer ou RightPlayer) não encontrados!")
		return
	
	# Inicializa as animações
	left_player.play("idle")
	right_player.play("idle")
	
	# Conecta o botão "RETORNAR"
	if button_retornar:
		button_retornar.pressed.connect(_on_retornar_pressed)
	
	# Preenche o array de texturas com os arquivos .jpg disponíveis
	character_textures = [
		preload("res://assets/char1_portrait.jpg"),
		preload("res://assets/char2_portrait.jpg"),
		preload("res://assets/char3_portrait.jpg"),
		preload("res://assets/char4_portrait.jpg")
	]
	
	# Verifica se os arquivos existem
	for texture in character_textures:
		if not texture:
			push_warning("Uma textura não foi carregada corretamente!")
	
	# Atualiza os avatares e jogadores
	update_avatars()

func update_avatars():
	# Atualiza os sprites dos jogadores
	if left_player and selected_left < character_textures.size():
		left_player.frames = load_character_frames(selected_left)
	if right_player and selected_right < character_textures.size():
		right_player.frames = load_character_frames(selected_right)
	
	# Atualiza os avatares com as texturas
	for i in range(avatars.size()):
		if i < character_textures.size() and avatars[i]:
			avatars[i].texture = character_textures[i]

func load_character_frames(character_index: int) -> SpriteFrames:
	var frames = SpriteFrames.new()
	if character_index >= 0 and character_index < character_textures.size():
		frames.add_frame("idle", character_textures[character_index])
		frames.set_animation_loop("idle", true)
	else:
		push_warning("Índice de personagem inválido: " + str(character_index))
	return frames

func _on_retornar_pressed():
	get_tree().change_scene_to_file("res://title_screen.tscn")  # Ajuste o caminho do menu principal

# Função para trocar seleção com teclas
func _input(event):
	if event.is_action_pressed("ui_left") and left_player:
		selected_left = (selected_left - 1) % character_textures.size()
		update_avatars()
	elif event.is_action_pressed("ui_right") and right_player:
		selected_right = (selected_right + 1) % character_textures.size()
		update_avatars()
