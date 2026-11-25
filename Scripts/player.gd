extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const AIR_DRAG = 100.0
const GROUND_DRAG = 10.0
const ROTATION_EASE = 25.0 #Lower is easier

var flipped: bool = false
var accel:float = 0
var pushing: bool = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		$Feet.region_rect.position.x = 64
		$Footanitimer.stop()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		if is_on_floor():
			velocity.x = direction * SPEED
			if $Footanitimer.is_stopped():
				$Footanitimer.start()
		else:
			velocity.x = clampf(velocity.x + (direction * SPEED/ROTATION_EASE), -SPEED, SPEED)
		if direction > 0:
			flipped = false
		else:
			flipped = true
	elif is_on_floor():
		#These extra else statements are meant to allow slight retention of speed while falling
		velocity.x = move_toward(velocity.x, 0, SPEED/GROUND_DRAG)
		if $Footanitimer.is_stopped():
			$Feet.region_rect.position.x = 0 #Takes care of times where you hit the ground from falling
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/AIR_DRAG)
	
	$Torso.flip_h = flipped
	$Feet.flip_h = flipped
	move_and_slide()
	
	#Apply forces to entities
	var force = 2000
	for i in get_slide_collision_count():
		#Get data from the collision
		var col = get_slide_collision(i)
		pushing = col.get_collider() is RigidBody2D
		if pushing:
			if col.get_collider_velocity().length() < SPEED:
				col.get_collider().apply_force(col.get_normal() * -force)


func _on_blinktimer_timeout() -> void:
	$Torso.region_rect.position.x += 64
	$Anitimer.start()


func _on_anitimer_timeout() -> void:
	if $Torso.region_rect.position.x < 192:
		$Torso.region_rect.position.x += 64
		$Anitimer.start()
	else:
		$Torso.region_rect.position.x = 0


func _on_footanitimer_timeout() -> void:
	if abs(velocity.x) < 300 and is_on_floor() and not pushing:
		print("slow")
		#If too slow (cuts out most of the times where the foot glitches)
		$Feet.region_rect.position.x = 0
		$Footanitimer.stop()
	else:
		$Feet.region_rect.position.x = fmod($Feet.region_rect.position.x + 64, 128.0)
