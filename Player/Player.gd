extends KinematicBody

# player attributes
export var health = 25
export var damage = 1
export var projectile_amount = 1

var can_fire = true
export var fire_cooldown = 0.5
export var fire_modifier = 1
export var projectile_speed = 1

var gem_count = 0
var next_level = 10

# mouse
var mouse_sensitivity = 0.1

# movment
var speed_base = 6
var movment_speed = speed_base

var sprint_modifier = 1.66
var crouch_modifier = 0.66
var momentum_modifier = 1

var acceleration_air = 3
var acceleration_ground = 24
var acceleration = acceleration_ground

var jump_strength = 10
var gravity = -40

var snap = Vector3.ZERO
var velocity_vertical = Vector3.ZERO
var velocity_horizontal = Vector3.ZERO
var direction_horizontal = Vector3.ZERO

# references
onready var global = get_node("/root/Global")
onready var head = $Head
onready var camera = $Head/Camera
onready var light = $Head/Camera/OmniLight
onready var offset = $Head/Camera/Offset
onready var death_screen = $HUD/DeathSreen
onready var level_up = $HUD/LevelUp
onready var sound = $AudioStreamPlayer
onready var sound2 = $AudioStreamPlayer2
onready var fire_timer = Timer.new()
onready var rng = RandomNumberGenerator.new()
onready var projectile = preload("res://Player/Projectile.tscn")
onready var level = preload("res://sounds/nice.wav")
onready var fire = preload("res://sounds/fire.wav")
onready var ded = preload("res://sounds/ded.wav")
onready var pickup = preload("res://sounds/pickup.wav")

func _ready():
	add_child(fire_timer)
	fire_timer.set_one_shot(true)
	mouse_sensitivity = global.mouse_sensitivity
	# lock mouse at start
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.set_as_toplevel(true)

func _unhandled_input(event):
	# mouse input
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x) * mouse_sensitivity)
		head.rotate_x(deg2rad(-event.relative.y) * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

	# key input
	if event is InputEventKey:
		# scale for crouch
		if event.is_action_pressed("move_crouch"):
			scale.y = 0.5
		if event.is_action_released("move_crouch"):
			scale.y = 1

func _physics_process(delta):
	# handle movment inputs
	movment(delta)
	shoot(delta)
	
	#light.light_energy = health/10
	light.omni_range = health
	clamp(light.omni_range,0,100)
	if health <= 0:
		sound.set_stream(ded)
		sound.play()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		death_screen.set_visible(true)
		get_tree().paused = true
	
	if gem_count >= next_level:
		next_level *= 2
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		level_up.set_visible(true)
		sound.set_stream(level)
		sound.play()
		get_tree().paused = true

func _process(delta):
	# camera smoothing
	camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, Engine.iterations_per_second/2 * delta)
	camera.rotation.x = head.rotation.x
	camera.rotation.y = rotation.y

func shoot(delta):
	if Input.is_action_pressed("action_fire") and fire_timer.is_stopped() and can_fire:
		fire_timer.start(fire_cooldown * fire_modifier)
		for p in projectile_amount:
			var projectile_instance = projectile.instance()
			projectile_instance.transform.origin = offset.global_transform.origin
			projectile_instance.rotation = camera.rotation + Vector3(rng.randf_range(-0.1,0.1),rng.randf_range(-0.1,0.1),rng.randf_range(-0.1,0.1))
			projectile_instance.apply_central_impulse(-projectile_instance.transform.basis.z * projectile_speed)
			get_tree().get_root().add_child(projectile_instance)
			sound.set_stream(fire)
			sound.play()
	elif !Input.is_action_pressed("action_fire"):
		var gems = get_tree().get_nodes_in_group("Gem")
		for gem in gems:
			gem.speed += 5 * delta

func movment(delta):
	if is_on_floor():
		acceleration = acceleration_ground
		if Input.is_action_just_pressed("move_jump"):
			snap = Vector3.ZERO
			velocity_vertical.y += jump_strength
		else:
			snap = -get_floor_normal()
			velocity_vertical.y = 0
		
		if Input.is_action_just_pressed("move_sprint"):
			can_fire = false
			movment_speed = speed_base * sprint_modifier
		if Input.is_action_just_pressed("move_crouch"):
			fire_modifier = 0.5
			movment_speed = speed_base * crouch_modifier
	else:
		acceleration = acceleration_air
		snap = Vector3.DOWN
		velocity_vertical.y += gravity * delta
	
	if Input.is_action_just_released("move_sprint"):
		can_fire = true
		movment_speed = speed_base
	if Input.is_action_just_released("move_crouch"):
		fire_modifier = 1
	
	direction_horizontal.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	direction_horizontal.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction_horizontal = transform.basis.xform(direction_horizontal) * movment_speed * momentum_modifier
	
	velocity_horizontal = velocity_horizontal.linear_interpolate(direction_horizontal, acceleration * delta)
	move_and_slide_with_snap(velocity_horizontal + velocity_vertical, snap, Vector3.UP)

func _on_PickupArea_body_entered(body):
	if body.is_in_group("Gem"):
		sound.set_stream(pickup)
		sound.play()
		gem_count += 1
		body.queue_free()


func _on_UpFireRate_pressed():
	fire_cooldown -= 0.1
	level_up.set_visible(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false

func _on_UpDamage_pressed():
	damage += 1
	level_up.set_visible(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false

func _on_UpProjectile_pressed():
	projectile_amount += 1
	level_up.set_visible(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
