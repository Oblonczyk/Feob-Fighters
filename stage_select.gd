extends Control

var selected_stage : String = ""  # Inicializa como string vazia

func _ready():
	# Inicializa a label do cenário
	if has_node("nome_cenario"):
		$nome_cenario.text = "Nenhum cenário selecionado"

	# Conecta os botões de cenário
	for button in $MarginContainer/GridContainer.get_children():
		if button is Button:
			button.pressed.connect(Callable(self, "_on_stage_button_pressed").bind(button))

	# Conecta botão RETORNAR
	if has_node("RETORNAR"):
		$RETORNAR.pressed.connect(_on_return_pressed)
	else:
		push_error("❌ Botão 'RETORNAR' não encontrado na cena!")

	# Conecta botão LUTA
	if has_node("LUTA"):
		$LUTA.pressed.connect(_on_confirm_pressed)
	else:
		push_error("❌ Botão 'LUTA' não encontrado na cena!")


# Quando o jogador clica em um cenário
func _on_stage_button_pressed(button: Button):
	selected_stage = button.name
	# Dicionário com nomes amigáveis
	var nomes_map = {
		"btn_laboratorio": "Laboratório",
		"btn_biblioteca": "Biblioteca",
		"btn_cantina": "Cantina",
		"btn_quadra": "Quadra",
		"btn_predio_e": "Prédio E",
		"btn_predio_a": "Prédio A",
		"btn_campus_unifeob": "Campus Unifeob",
		"btn_estacionamento": "Estacionamento"
	}
	var nome_formatado = nomes_map.get(button.name, button.name.trim_prefix("btn_").replace("_", " ").capitalize())
	
	# Verifica e atualiza a label
	if has_node("nome_cenario"):
		var label = $nome_cenario
		label.text = nome_formatado
		print("✅ Clicou no cenário:", nome_formatado)
	else:
		push_error("❌ Label 'nome_cenario' NÃO ENCONTRADA ao tentar atualizar!")
	
	print("🔍 Nome do botão:", button.name)  # Debug adicional

# Quando clica em LUTA
func _on_confirm_pressed():
	if selected_stage != "":
		print("🎮 Cenário confirmado:", selected_stage)
		match selected_stage:
			"btn_biblioteca": get_tree().change_scene_to_file("res://stages/biblioteca.tscn")
			"btn_cantina": get_tree().change_scene_to_file("res://stages/cantina.tscn")
			"btn_laboratorio": get_tree().change_scene_to_file("res://stages/laboratorio.tscn")
			"btn_quadra": get_tree().change_scene_to_file("res://stages/quadra.tscn")
			"btn_predio_e": get_tree().change_scene_to_file("res://stages/predio_e.tscn")
			"btn_predio_a": get_tree().change_scene_to_file("res://stages/predio_a.tscn")
			"btn_campus_unifeob": get_tree().change_scene_to_file("res://stages/campus.tscn")
			"btn_estacionamento": get_tree().change_scene_to_file("res://stages/estacionamento.tscn")
			_: push_warning("⚠️ Cena não configurada para esse botão.")
	else:
		if has_node("nome_cenario"):
			$nome_cenario.text = "Selecione um cenário!"
		print("❌ Nenhum cenário selecionado.")


# Quando clica em RETORNAR
func _on_return_pressed():
	print("↩️ Retornando à seleção de personagem...")
	get_tree().change_scene_to_file("res://character_select/character_select.tscn")
