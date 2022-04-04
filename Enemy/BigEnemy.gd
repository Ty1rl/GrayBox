extends RigidBody

export var health = 6
export var damage = 4
export var attack_rate = 0.5
export var speed = 20

var direction = Vector3.ZERO

onready var mesh = $MeshInstance
onready var attack_timer = $AttackTimer
onready var sound = $AudioStreamPlayer
onready var players = get_tree().get_nodes_in_group("Player")
onready var gem = preload("res://Items/Gem.tscn")
onready var playerhit = preload("res://sounds/playerHit.wav")
onready var kill = preload("res://sounds/kill.wav")
onready var hum = preload("res://sounds/hum.wav")

func _ready():
	mesh.set_as_toplevel(true)

func _physics_process(delta):
	# remove when dead
	if health <= 0:
		players[0].sound2.set_stream(kill)
		players[0].sound2.play()
		var gem_instance = gem.instance()
		gem_instance.transform.origin = global_transform.origin
		get_tree().get_root().add_child(gem_instance)
		queue_free()
	elif !sound.is_playing():
		sound.set_stream(hum)
		sound.play()
	
	# move towards player
	if players.size() > 0:
		if is_instance_valid(players[0]):
			direction = (players[0].global_transform.origin - global_transform.origin).normalized()
			add_central_force(direction * speed)

func _process(delta):
	# smooth movement
	mesh.global_transform.origin = mesh.global_transform.origin.linear_interpolate(global_transform.origin, Engine.iterations_per_second/2 * delta)
	mesh.rotation = rotation

func _on_Enemy_body_entered(body):
	if body.is_in_group("Player"):
		attack_timer.start(0.1)

func _on_Enemy_body_exited(body):
	if body.is_in_group("Player"):
		attack_timer.stop()

func _on_AttackTimer_timeout():
	if players.size() > 0:
		if is_instance_valid(players[0]):
			sound.set_stream(playerhit)
			sound.play()
			players[0].health -= damage
