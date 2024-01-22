extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var explode_timer = 200

var dir = 0

var Player = load("res://Player.tscn")
var Particle = load("res://explode_particle.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	get_node("Explode").position.y = -50

func _process(delta):
	if explode_timer > 0:
		explode_timer -= 1
		if explode_timer < 100:
			scale += Vector3(0.01,0.01,0.01)
		if explode_timer == 5:
			get_node("Explode").position.y = 0
			var particle = Particle.instantiate()
			particle.position = position
			particle.position.y += 1
			get_node("/root/Map").add_child(particle)
	else:
		
		queue_free()
		

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		print(dir)
		velocity.y -= gravity * delta
		if dir >= -45 and dir <= 45:
			position.z -= 0.1
		elif dir >= 120 or dir <= -120:
			position.z += 0.1
		elif dir >= 45 and dir <= 135:
			position.x -= 0.1
		elif dir >= -120 and dir <= -45:
			position.x += 0.1

	move_and_slide()
