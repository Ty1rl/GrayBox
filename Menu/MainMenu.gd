extends Control

onready var fps_limit = Engine.target_fps
onready var volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"))

onready var global = get_node("/root/Global")
onready var main = $CenterContainer/Main
onready var settings = $CenterContainer/Settings
onready var volume_slider = $CenterContainer/Settings/HBoxContainer/VolumeSlider
onready var Sensitivity_slider = $CenterContainer/Settings/HBoxContainer2/SensitivitySlider
onready var fps = $CenterContainer/Settings/HBoxContainer4/SpinBox

func _ready():
	volume_slider.set_value(volume)
	Sensitivity_slider.set_value(global.mouse_sensitivity)
	fps.set_value(fps_limit)

func _on_PlayButton_pressed():
	get_tree().change_scene("res://Level/Level.tscn")

func _on_SettingsButton_pressed():
	main.set_visible(false)
	settings.set_visible(true)

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_BackButton_pressed():
	main.set_visible(true)
	settings.set_visible(false)

func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),value)

func _on_SensitivitySlider_value_changed(value):
	global.mouse_sensitivity = value

func _on_CheckButton_toggled(button_pressed):
	OS.window_fullscreen = button_pressed

func _on_SpinBox_value_changed(value):
	fps_limit = value
	Engine.target_fps = fps_limit
