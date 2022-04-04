extends CanvasLayer

onready var menu = $CenterContainer

func _process(delta):
	# togle cursor lock
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			menu.set_visible(true)
			get_tree().paused = true
		else:
			get_tree().paused = false
			menu.set_visible(false)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_ContinueButton_pressed():
	get_tree().paused = false
	menu.set_visible(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_MenuButton_pressed():
	get_tree().paused = false
	for e in get_tree().get_nodes_in_group("Enemy"):
		e.queue_free()
	for g in get_tree().get_nodes_in_group("Gem"):
		g.queue_free()
	get_tree().change_scene("res://Menu/MainMenu.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
