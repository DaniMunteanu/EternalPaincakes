extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum player_orientation {LEFT, RIGHT}
var current_player_orientation = player_orientation.RIGHT

enum player_states {IDLE, WALKING, HOLDING_JUMP, IN_AIR, DEAD}
var current_player_state = player_states.IDLE

@export var walking_speed = 300.0
@export_range(0,1) var acceleration = 0.1
@export_range(0,1) var deceleration = 0.1

@export var jump_force = -400.0
@export_range(0,1) var jump_deceleration = 0.1

var current_jump_velocity = 500.0
var max_jump_velocity = -1000.0
var jump_force_increment = 250.0

var max_flying_velocity = 1000.0
var current_flying_velocity = 0.0

var flying_orientation_modifier = 0.0

func update_player_orientation():
	var walking_angle = rad_to_deg(velocity.angle())
	if walking_angle < 0:
		walking_angle += 360
	match floor(walking_angle/90.0):
		1.0, 2.0:
			current_player_orientation = player_orientation.LEFT
		0.0, 3.0:
			current_player_orientation = player_orientation.RIGHT

func update_walking_movement():
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * walking_speed, walking_speed * acceleration)
		current_player_state = player_states.WALKING
		print("walking")
	else:
		velocity.x = move_toward(velocity.x, 0, walking_speed * deceleration)
		current_player_state = player_states.IDLE
		print("idle")

func check_for_jump():
	if Input.is_action_just_released("jump"):
		velocity.x = 100.0 * flying_orientation_modifier
		velocity.y = current_jump_velocity
		animation_player.play("PlayerFloat")
		current_player_state = player_states.IN_AIR
		print("in aer")
	elif Input.is_action_pressed("jump") and is_on_floor():
		#velocity.y = jump_force
		velocity.x = 0.0
		current_player_state = player_states.HOLDING_JUMP
		print("holding jump")

func check_if_in_air():
	if not is_on_floor():
		current_player_state = player_states.IN_AIR
		print("in air")

func _physics_process(delta: float) -> void:
	match current_player_state:
		player_states.IDLE:
			#update_player_orientation()
			flying_orientation_modifier = 0.0
			update_walking_movement()
			check_for_jump()
			check_if_in_air()
			match current_player_orientation:
				player_orientation.LEFT:
					animation_player.play("PlayerIdleLeft")
				player_orientation.RIGHT:
					animation_player.play("PlayerIdleRight")
				
		player_states.WALKING:
			update_player_orientation()
			update_walking_movement()
			check_if_in_air()
			match current_player_orientation:
				player_orientation.LEFT:
					animation_player.play("PlayerWalkingLeft")
					flying_orientation_modifier = -1.0
				player_orientation.RIGHT:
					animation_player.play("PlayerWalkingRight")
					flying_orientation_modifier = 1.0
			check_for_jump()
					
		player_states.HOLDING_JUMP:
			if Input.is_action_just_released("jump"):
				velocity.x = current_flying_velocity * flying_orientation_modifier
				current_flying_velocity = 0.0
				flying_orientation_modifier = 0.0
				
				velocity.y = current_jump_velocity
				current_jump_velocity = 500.0
				animation_player.play("PlayerFloat")
				current_player_state = player_states.IN_AIR
			else:
				flying_orientation_modifier = 0.0
				if Input.is_action_pressed("move_left") == Input.is_action_pressed("move_right"):
					flying_orientation_modifier = 0.0
				elif Input.is_action_pressed("move_left"):
					flying_orientation_modifier = -1.0
				else:
					flying_orientation_modifier = 1.0
					
				animation_player.play("PlayerHoldingJump")
				current_jump_velocity = move_toward(current_jump_velocity, max_jump_velocity, delta * jump_force_increment)
				
				current_flying_velocity = move_toward(current_flying_velocity, max_flying_velocity, delta * jump_force_increment)
				
		player_states.IN_AIR:
			if is_on_floor():
				current_player_state = player_states.IDLE
				print("idle")
			else:
				velocity += get_gravity() * delta
				animation_player.play("PlayerFloat")
	#update_player_orientation()
	
	# Add the gravity.
	
		

	# Handle jump.
	
		
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
		

	move_and_slide()
