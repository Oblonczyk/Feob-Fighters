extends Control

@onready var sprite_player = $HBoxContainer/LeftPlayer/AnimatedSprite2D
@onready var nome_label = $NOME_PERSONAGEM

const TITLE_SCREEN = "res://title_screen.tscn"
const SCENARIO_SELECT = "res://stages/stage_select.tscn"

# Dicionário de personagens (nome + animação existente no AnimatedSprite2D)
var personagens = {
	"TextureButton": "MARUDI",
	"TextureButton2": "MARCELO",
	"TextureButton3": "CARLOS",
	"TextureButton4": "LUIS"
}

var personagem_selecionado = null

func _ready():
	# Conecta os botões de personagem
	for button_name in personagens.keys():
		var botao = get_node(button_name)
		if botao:
			botao.pressed.connect(func(): _selecionar_personagem(button_name))
		else:
			push_warning("⚠ Botão '%s' não encontrado!" % button_name)

	# Conecta botões RETORNAR e LUTA
	if $BottomMenu.has_node("RETORNAR"):
		$BottomMenu/RETORNAR.pressed.connect(_on_return_pressed)
	else:
		push_error("❌ Nó RETORNAR não encontrado dentro de BottomMenu!")

	if $BottomMenu.has_node("LUTA"):
		$BottomMenu/LUTA.pressed.connect(_on_fight_pressed)
	else:
		push_error("❌ Nó LUTA não encontrado dentro de BottomMenu!")

	# Estado inicial
	sprite_player.stop()
	nome_label.text = ""

# 🧍 Seleção do personagem
func _selecionar_personagem(button_name: String):
	var anim_name = personagens[button_name]
	personagem_selecionado = anim_name

	# Atualiza o nome no label
	nome_label.text = anim_name

	# Verifica se a animação existe e toca
	if sprite_player.sprite_frames.has_animation(anim_name):
		sprite_player.play(anim_name)
		print("✅ Personagem selecionado:", anim_name)
	else:
		push_warning("⚠ Animação '%s' não encontrada!" % anim_name)
		sprite_player.stop()

# 🔙 Retornar para a tela inicial
func _on_return_pressed():
	print("↩ Voltando para a tela inicial...")
	get_tree().change_scene_to_file("res://title_screen/title_screen.tscn")

# 🥊 Ir para seleção de cenário
func _on_fight_pressed():
	if personagem_selecionado == null:
		print("❌ Nenhum personagem selecionado!")
		nome_label.text = "Selecione um personagem!"
	else:
		print("🎮 Indo para seleção de cenário com:", personagem_selecionado)
		get_tree().change_scene_to_file(SCENARIO_SELECT)
