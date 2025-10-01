extends Control


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://level.tscn")


func _on_opções_pressed() -> void:
	pass # Replace with function body.


func _on_sair_pressed() -> void:
	get_theme().quit()
