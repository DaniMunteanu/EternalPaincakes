extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var jump_progress_bar: TextureProgressBar = $JumpProgressBar

enum player_orientation {LEFT, RIGHT}
var current_player_orientation = player_orientation.RIGHT

enum player_states {IDLE, WALKING, HOLDING_JUMP, IN_AIR, DEAD}
var current_player_state = player_states.IDLE

@export var walking_speed = 80.0
@export_range(0,1) var acceleration = 0.1
@export_range(0,1) var deceleration = 0.1

var current_jump_velocity_y = 0.0
const MAX_JUMP_VELOCITY_Y = -1000.0
const JUMP_FORCE_INCREMENT = 10.0

var current_jump_velocity_x = 0.0
const MAX_JUMP_VELOCITY_X = 1000.0

var jump_orientation_modifier = 0.0

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
	else:
		velocity.x = move_toward(velocity.x, 0, walking_speed * deceleration)
		current_player_state = player_states.IDLE

func check_for_jump():
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.x = 0.0
		jump_progress_bar.visible = true
		current_player_state = player_states.HOLDING_JUMP

func check_if_in_air():
	if not is_on_floor():
		current_player_state = player_states.IN_AIR
		
func _physics_process(delta: float) -> void:
	match current_player_state:
		player_states.IDLE:
			#update_player_orientation()
			jump_orientation_modifier = 0.0
			update_walking_movement()
			check_if_in_air()
			match current_player_orientation:
				player_orientation.LEFT:
					animation_player.play("PlayerIdleLeft")
				player_orientation.RIGHT:
					animation_player.play("PlayerIdleRight")
			check_for_jump()
				
		player_states.WALKING:
			update_player_orientation()
			update_walking_movement()
			check_if_in_air()
			match current_player_orientation:
				player_orientation.LEFT:
					animation_player.play("PlayerWalkingLeft")
					jump_orientation_modifier = -1.0
				player_orientation.RIGHT:
					animation_player.play("PlayerWalkingRight")
					jump_orientation_modifier = 1.0
			check_for_jump()
					
		player_states.HOLDING_JUMP:
			if Input.is_action_just_released("jump"):
				current_jump_velocity_y = move_toward(current_jump_velocity_y, MAX_JUMP_VELOCITY_Y, jump_progress_bar.value * JUMP_FORCE_INCREMENT)
				current_jump_velocity_x = move_toward(current_jump_velocity_x, MAX_JUMP_VELOCITY_X, jump_progress_bar.value * JUMP_FORCE_INCREMENT)
				
				velocity.x = current_jump_velocity_x * jump_orientation_modifier
				current_jump_velocity_x = 0.0
				jump_orientation_modifier = 0.0
				
				velocity.y = current_jump_velocity_y
				current_jump_velocity_y = 0.0
				animation_player.play("PlayerFloat")
				
				jump_progress_bar.reset()
				current_player_state = player_states.IN_AIR
			else:
				jump_orientation_modifier = 0.0
				if Input.is_action_pressed("move_left") == Input.is_action_pressed("move_right"):
					jump_orientation_modifier = 0.0
				elif Input.is_action_pressed("move_left"):
					jump_orientation_modifier = -1.0
				else:
					jump_orientation_modifier = 1.0
					
				animation_player.play("PlayerHoldingJump")
				
				jump_progress_bar.tick()
				
		player_states.IN_AIR:
			if is_on_floor():
				velocity.x = 0.0
				current_player_state = player_states.IDLE
			else:
				velocity += get_gravity() * delta
				animation_player.play("PlayerFloat")
	#update_player_orientation()
	
	# Add the gravity.
	
		

	# Handle jump.
	
		
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
		

	move_and_slide()
