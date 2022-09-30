extends Menu

func _ready() -> void:
# warning-ignore:narrowing_conversion
	Engine.target_fps = OS.get_screen_refresh_rate()


func on_make_server_pressed() -> void:
	qNetwork.create_server(Resources.get_map_name(Resources.map_names.PLAYGROUND))


func on_join_server_pressed()-> void:
	qNetwork.connect_to_server()
