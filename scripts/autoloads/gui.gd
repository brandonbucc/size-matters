extends CanvasLayer

var gui_components = [
	"res://scenes/options.tscn"
]

var resolutions = {
	"3840x2160": Vector2i(3840, 2160),
	"2560x1440": Vector2i(2560, 1440),
	"1920x1080": Vector2i(1920, 1080),
	"1280x720": Vector2i(1280, 720)
}

var config = ConfigFile.new()
var err = config.load("res://config/config.cfg")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if err == OK:
		var key = config.get_value("Video", "resolution")
		get_window().set_size(resolutions[key])
		centre_window()
	for i in gui_components:
		var new_scene = load(i).instantiate()
		add_child(new_scene)
		new_scene.hide()

func _input(_event):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			get_tree().paused = false
		else:
			get_tree().paused = true
		var options = get_node("Options")
		options.visible = !options.visible
		if options.visible:
			options.update_button_values()

func centre_window():
	var screen_centre = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = DisplayServer.window_get_size_with_decorations()
	get_window().set_position(screen_centre - window_size / 2)

func return_to_game():
	if get_tree().paused:
		get_tree().paused = false
	else:
		get_tree().paused = true
	var options = get_node("Options")
	options.visible = !options.visible
	if options.visible:
		options.update_button_values()
