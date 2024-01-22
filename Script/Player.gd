extends CharacterBody3D

signal health_changed(health_value)

@onready var camera = $Camera3D

const Bomb = preload("res://Scenes/Bomb.tscn")
const Mur = preload("res://Scenes/Mur.tscn")

var rng = RandomNumberGenerator.new()
var wfocus = false

var health = 3

const SPEED = 10
const JUMP_VELOCITY = 10

var gravity = 20

var animation_mode = 0

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	$Body/Label3D.text = str(name)
	$Body/Label3D.visible = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	
#	if is_multiplayer_authority():
#		for i in 250:
#			var x = rng.randi_range(-20,20)
#			var z = rng.randi_range(-20,20)
#			for y in 5:
#				add_wall.rpc(Vector3(x,y,z))
#				add_wall(Vector3(x,y,z))

func _process(_delta):
	get_node("Body/Propellers").rotation.y += 0.25
	
	if $Body.position.y < 2 and animation_mode == 0:
		$Body.position.y += 0.01
	elif $Body.position.y >= 2 and animation_mode == 0:
		animation_mode = 1
		
	if $Body.position.y > 1 and animation_mode == 1:
		$Body.position.y -= 0.01
	elif $Body.position.y <= 1 and animation_mode == 1:
		animation_mode = 0
		
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("pose"):
		add_bomb.rpc(position,rotation_degrees.y)
		if is_multiplayer_authority():
			add_bomb(position,rotation_degrees.y)
		else: return
	

@rpc("any_peer")
func receive_damage(damage):
	health -= damage
	if health <= 0:
		health = 3
		position = Vector3.ZERO
	health_changed.emit(health)

@rpc("any_peer")
func add_bomb(pos,rot):
	var bomb = Bomb.instantiate()
	bomb.name = "BombID"+str(rng.randi_range(0,999999))
	bomb.position = pos
	bomb.dir = rot
	get_node("/root/Map").add_child(bomb)

@rpc("any_peer")
func add_wall(pos):
	var wall = Mur.instantiate()
	wall.name = "WallID"+str(rng.randi_range(0,999999))
	wall.position = pos
	get_node("/root/Map").add_child(wall)
	print("Spawned wall")

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		#camera.rotate_x(-event.relative.y * 0.005)
		#camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func _notification(what):

	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		wfocus = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		wfocus = false


func _on_area_3d_area_entered(area):
	if area.is_in_group("Bomb"):
		print(float(1)/(multiplayer.get_peers().size()+1))
		if get_multiplayer_authority() == 1: receive_damage.rpc_id(get_multiplayer_authority(),float(1)/(multiplayer.get_peers().size()+1))
		else: receive_damage.rpc_id(get_multiplayer_authority(),1)
