extends CanvasLayer

onready var fps = $FPS
onready var time = $Time
onready var gems = $Gems

onready var player = get_parent()

var timer = 0

func _process(delta):
	fps.text = str(Engine.get_frames_per_second())
	
	timer += delta
	time.text = str(timer)
	
	gems.text = str(player.gem_count)


func _on_PlayButton_pressed():
	get_tree().paused = false
	for e in get_tree().get_nodes_in_group("Enemy"):
		e.queue_free()
	for g in get_tree().get_nodes_in_group("Gem"):
		g.queue_free()
	get_tree().reload_current_scene()

func _on_MenuButton_pressed():
	get_tree().paused = false
	for e in get_tree().get_nodes_in_group("Enemy"):
		e.queue_free()
	for g in get_tree().get_nodes_in_group("Gem"):
		g.queue_free()
	get_tree().change_scene("res://Menu/MainMenu.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
