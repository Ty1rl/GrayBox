extends GridMap

onready var player = $Player
onready var spawner = preload("res://Enemy/Spawner.tscn")

onready var rng = RandomNumberGenerator.new()
onready var noise = OpenSimplexNoise.new()

const load_distance = 1
var loaded_cells = PoolVector3Array()

func _ready():
	rng.randomize()
	noise.seed = rng.randi()
	noise.octaves = 8
	noise.period = 64.0
	noise.persistence = 0.5

func _physics_process(_delta):
	get_cells_to_load()
	load_cells()
	unload_cells()

func get_cells_to_load():
	# clear pool
	loaded_cells.resize(0)
	# get cell player is in
	var cell = world_to_map(player.global_transform.origin)
	# add surrounding cells to pool
	for x in range(-load_distance,load_distance+1):
		for z in range(-load_distance,load_distance+1):
			loaded_cells.append(Vector3(cell.x + x, 0, cell.z + z))
			loaded_cells.append(Vector3(cell.x + x, 1, cell.z + z))

func load_cells():
	for cell in loaded_cells:
		# load floor
		set_cell_item(cell.x, 0, cell.z, 0)
		# load piller at random
		if noise.get_noise_2d(cell.x, cell.z) > 0:
			set_cell_item(cell.x, 1, cell.z, 1)

func unload_cells():
	for cell in get_used_cells():
		if !cell in loaded_cells:
			set_cell_item(cell.x, 0, cell.z, -1)

func _on_SpawnTimer_timeout():
		var s = spawner.instance()
		s.transform.origin = player.transform.origin + (player.transform.basis.z * 25) + Vector3(0,7,0)
		get_tree().get_root().add_child(s)
