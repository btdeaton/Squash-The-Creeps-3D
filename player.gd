extends CharacterBody3D

signal hit

# Set how fast a player moves in meters per sec
@export var speed = 14

# The downward acceleration when in the air, in meters per sec
@export var fall_acceleration = 75

# Vertical impulse applied to the character when jumping in meters per sec
@export var jump_impulse = 20

# Vertical impules applied to the character jumping over a mob in m/s
@export var bounce_impulse = 16

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	# We create a local variable to store the input direction
	var direction = Vector3.ZERO
	
	# We check for what move is inputted and update the direction
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	# Notice how the 3D vector has a Z axis, in 3D the ground plane is X and Z
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property that will affect the rotation of the node
		$Pivot.basis = Basis.looking_at(direction)
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1
	
	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	# Vertical Velocity
	if not is_on_floor(): #If in the air, fall to the floor.
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	
	# Jumping.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
	
	# Iterate through all collisions that occured this frame
	for index in range(get_slide_collision_count()):
		# We get one of the collisions with the player
		var collision = get_slide_collision(index)
		
		# If there are duplicate collisions with a mob in a single frame
		# the mob will be deleted after the first collision, and a second call to
		# get_collider will return null, leading to a null pointer when calling
		# collision.get_collider().is_in_group('mob').
		# This block of code prevents processing duplicate collisions.
		if collision.get_collider() == null:
			continue
		
		# If the collider is with a mob
		if collision.get_collider().is_in_group('mob'):
			var mob = collision.get_collider()
			# We check that we are hitting it from above
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# If so, we squash it and bounce
				mob.squash()
				target_velocity.y = bounce_impulse
				# Prevent further duplicate calls
				break
	# Moving the Character
	velocity = target_velocity
	move_and_slide()
	
	$Pivot.rotation.x = PI / 6 * velocity.y / jump_impulse

func die():
	hit.emit()
	queue_free()

func _on_mob_detector_body_entered(body):
	die()
