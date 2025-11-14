extends Node2D

func _ready():
	# Play butonuna bağla
	var play_button = $Play
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	
	# Exit butonuna bağla
	var exit_button = $exit
	if exit_button:
		exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	# Main sahnesine geç
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_exit_pressed():
	# Oyundan çık
	get_tree().quit()
