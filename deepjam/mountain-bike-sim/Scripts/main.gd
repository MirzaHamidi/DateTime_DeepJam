extends Node3D

@onready var ui_layer: CanvasLayer = $uı
@onready var menu_panel: Control = $uı/MenuPanel
@onready var main_menu_button: Button = $uı/MenuPanel/MainMenuButton

var is_menu_open: bool = false

func _ready():
	# UI'ı başlangıçta gizle
	if menu_panel:
		menu_panel.visible = false

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):  # ESC tuşu
		toggle_menu()
		get_viewport().set_input_as_handled()  # Event'i handle et, başka yerlere gitmesin

func toggle_menu():
	is_menu_open = !is_menu_open
	
	if menu_panel:
		menu_panel.visible = is_menu_open
	
	# Mouse modunu değiştir
	if is_menu_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_main_menu_button_pressed():
	# Main menu'ye dön
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
