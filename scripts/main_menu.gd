extends Control

func _ready():
	$VBoxContainer/NewGame.grab_focus()

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_continue_pressed() -> void:
	pass

func _on_quit_pressed():
	get_tree().quit()
