extends KinematicBody

export var health = 25
export var speed = 1
export var spawn_rate = 1

var life_time = 0

var direction = Vector3.ZERO

onready var mesh = $MeshInstance
onready var sound = $AudioStreamPlayer
onready var enemy = preload("res://Enemy/Enemy.tscn")
onready var big_enemy = preload("res://Enemy/BigEnemy.tscn")
onready var spawn_timer = Timer.new()
onready var players = get_tree().get_nodes_in_group("Player")
onready var kill = preload("res://sounds/spawnkill.wav")
onready var hum = preload("res://sounds/hum.wav")

func _ready():
	mesh.set_as_toplevel(true)
	add_child(spawn_timer)
	spawn_timer.set_one_shot(true)

func _physics_process(delta):
	# remove when dead
	if health <= 0:
		players[0].sound2.set_stream(kill)
		players[0].sound2.play()
		queue_free()
	elif !sound.is_playing():
		sound.set_stream(hum)
		sound.play()
	
	# spin
	rotate_y(0.5 * delta)
	# move towards player
	if players.size() > 0:
		if is_instance_valid(players[0]):
			direction.x = (players[0].global_transform.origin.x - global_transform.origin.x)
			direction.z = (players[0].global_transform.origin.z - global_transform.origin.z)
			move_and_slide(direction * speed * delta)

func _process(delta):
	# smooth movement
	mesh.global_transform.origin = mesh.global_transform.origin.linear_interpolate(global_transform.origin, Engine.iterations_per_second/2 * delta)
	mesh.rotation = rotation
	
	life_time += delta
	if spawn_timer.is_stopped() and get_tree().get_nodes_in_group("Enemy").size() < 750:
		if life_time > 60:
			spawn_timer.start(spawn_rate)
			var e = big_enemy.instance()
			e.transform.origin = global_transform.origin + Vector3(0,7,0)
			get_tree().get_root().add_child(e)
		else:
			spawn_timer.start(spawn_rate)
			var e = enemy.instance()
			e.transform.origin = global_transform.origin + Vector3(0,7,0)
			get_tree().get_root().add_child(e)
