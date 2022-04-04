extends RigidBody

var damage = 1
var lifetime = 0

onready var mesh = $MeshInstance

onready var players = get_tree().get_nodes_in_group("Player")
onready var hit = preload("res://sounds/hit.wav")

func _ready():
	mesh.set_as_toplevel(true)

func _process(delta):
	# smooth movement
	mesh.global_transform.origin = mesh.global_transform.origin.linear_interpolate(global_transform.origin, Engine.iterations_per_second/2 * delta)
	mesh.rotation = rotation
	
	# remove if alive too long
	lifetime += lifetime * delta
	if lifetime > 5:
		queue_free()

func _on_Projectile_body_entered(body):
	if body.is_in_group("Enemy"):
		body.health -= damage
		players[0].sound.set_stream(hit)
		players[0].sound.play()
	# remove on any collision
	queue_free()
