extends Node3D

var finished = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print($Explosion.emission_sphere_radius)
	if $Explosion.emission_sphere_radius > 2:
		finished = 1
	if finished == 0:
		$Explosion.emission_sphere_radius += 0.1
	else:
		if $Explosion.amount > 1:
			$Explosion.amount -= 1
		else:
			queue_free()
