extends Control

func _ready() -> void:
	# Caminhos ajustados conforme a hierarquia da cena
	var start_button = get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/Start")
	if start_button and start_button is Button:
		start_button.pressed.connect(_on_Start_pressed)
		print("Botão Start conectado com sucesso às ", Time.get_datetime_string_from_system())
	else:
		printerr("Erro: Botão Start não encontrado ou não é um Button às ", Time.get_datetime_string_from_system())

	var opcao_button = get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/Opção")
	if opcao_button and opcao_button is Button:
		opcao_button.pressed.connect(_on_opção_pressed)
	else:
		printerr("Erro: Botão Opção não encontrado.")

	var sair_button = get_node_or_null("MarginContainer/HBoxContainer/VBoxContainer/Sair")
	if sair_button and sair_button is Button:
		sair_button.pressed.connect(_on_sair_pressed)
	else:
		printerr("Erro: Botão Sair não encontrado.")


func _on_Start_pressed() -> void:
	print("Redirecionando para character_select.tscn às ", Time.get_datetime_string_from_system())
	var error = get_tree().change_scene_to_file("res://character_select/character_select.tscn")
	if error != OK:
		printerr("Erro ao carregar character_select.tscn: ", error)
	else:
		print("Cena 'character_select.tscn' carregada com sucesso!")


func _on_opção_pressed() -> void:
	print("Opções ainda não implementadas às ", Time.get_datetime_string_from_system())


func _on_sair_pressed() -> void:
	print("Saindo do jogo às ", Time.get_datetime_string_from_system())
	get_tree().quit()
