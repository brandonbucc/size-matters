extends Control

const CONFIG_PATH = "res://config/config.cfg"

@export var music_bus_name = "Music"
@export var sfx_bus_name = "SFX"

@onready var resolution = $PanelContainer/MarginContainer/VBoxContainer/Resolution
@onready var fullscreen = $PanelContainer/MarginContainer/VBoxContainer/Fullscreen
@onready var music_slider = $PanelContainer/MarginContainer/VBoxContainer/VolSlider
@onready var sfx_slider = $PanelContainer/MarginContainer/VBoxContainer/VolSlider2
@onready var music_bus = AudioServer.get_bus_index(music_bus_name)
@onready var sfx_bus = AudioServer.get_bus_index(sfx_bus_name)

var config = ConfigFile.new()
var err = config.load(CONFIG_PATH)

func _ready():
	if !FileAccess.file_exists(CONFIG_PATH):
		config.set_value("Video", "resolution", "1280x720")
		config.set_value("Video", "fullscreen", false)
		config.set_value("Audio", "music", 1)
		config.set_value("Audio", "sfx", 1)
		config.save(CONFIG_PATH)
	if err == OK:
		resolution.selected = GUI.resolutions.keys().find(config.get_value("Video", "resolution"))
		fullscreen.button_pressed = config.get_value("Video", "fullscreen")
		music_slider.value = config.get_value("Audio", "music")
		sfx_slider.value = config.get_value("Audio", "sfx")
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	add_resolutions()

func add_resolutions():
	for r in GUI.resolutions:
		resolution.add_item(r)

func update_button_values():
	var window_size_string = str(get_window().size.x, "x", get_window().size.y)
	var resolutions_index = GUI.resolutions.keys().find(window_size_string)
	resolution.selected = resolutions_index

func _on_resolution_item_selected(index):
	var key = resolution.get_item_text(index)
	get_window().set_size(GUI.resolutions[key])
	GUI.centre_window()
	config.set_value("Video", "resolution", key)
	config.save(CONFIG_PATH)

func _on_fullscreen_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		resolution.disabled = true
		config.set_value("Video", "fullscreen", true)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		GUI.centre_window()
		resolution.disabled = false
		var key = resolution.get_item_text(resolution.selected)
		get_window().set_size(GUI.resolutions[key])
		GUI.centre_window()
		config.set_value("Video", "fullscreen", false)
	config.save(CONFIG_PATH)

func _on_vol_slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))

func _on_vol_slider_2_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))

func _on_vol_slider_drag_ended(_value_changed):
	config.set_value("Audio", "music", music_slider.value)
	config.save(CONFIG_PATH)

func _on_vol_slider_2_drag_ended(_value_changed):
	config.set_value("Audio", "sfx", sfx_slider.value)
	config.save(CONFIG_PATH)

func _on_return_pressed() -> void:
	GUI.return_to_game()

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	GUI.return_to_game()
