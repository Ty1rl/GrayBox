extends RigidBody

export var speed = 10
var lifetime = 0

var direction = Vector3.ZERO

onready var mesh = $MeshInstance
onready var players = get_tree().get_nodes_in_group("Player")

func _ready():
	mesh.set_as_toplevel(true)

func _physics_process(delta):
	if players.size() > 0:
		if is_instance_valid(players[0]):
			direction = (players[0].global_transform.origin - global_transform.origin).normalized()
			add_central_force(direction * speed)
	
func _process(delta):
	# smooth movement
	mesh.global_transform.origin = mesh.global_transform.origin.linear_interpolate(global_transform.origin, Engine.iterations_per_second/2 * delta)
	mesh.rotation = rotation
	
	# remove if alive too long
	lifetime += lifetime * delta
	if lifetime > 5:
		queue_free()
