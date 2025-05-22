extends CharacterBody2D


const ACCEL = 2000.0
const MAX_SPEED = 250.0
const JUMP_VELOCITY = -400.0
var isWalking = false


func _physics_process(delta: float) -> void:
	isWalking = false;
	
	# left-right movement
	if Input.is_action_pressed("right") && !Input.is_action_pressed("left"):
		velocity.x = min(velocity.x + ACCEL*delta, MAX_SPEED);
		isWalking = true;
		$AnimatedSprite2D.flip_h = false;
	elif Input.is_action_pressed("left")  && !Input.is_action_pressed("right"):
		velocity.x = max(velocity.x - ACCEL*delta, MAX_SPEED*-1);
		isWalking = true;
		$AnimatedSprite2D.flip_h = true;
	else:
		if velocity.x > 0:
			velocity.x = max(velocity.x - ACCEL*delta, 0);
		elif velocity.x < 0:
			velocity.x = min(velocity.x + ACCEL*delta, 0);
	
	# up-down movement
	if Input.is_action_pressed("down") && !Input.is_action_pressed("up"):
		velocity.y = min(velocity.y + ACCEL*delta, MAX_SPEED);
		isWalking = true;
	elif Input.is_action_pressed("up")  && !Input.is_action_pressed("down"):
		velocity.y = max(velocity.y - ACCEL*delta, MAX_SPEED*-1);
		isWalking = true;
	else:
		if velocity.y > 0:
			velocity.y = max(velocity.y - ACCEL*delta, 0);
		elif velocity.y < 0:
			velocity.y = min(velocity.y + ACCEL*delta, 0);
	
	# animation
	if(isWalking):
		$AnimatedSprite2D.play("run");
	else:
		$AnimatedSprite2D.play("idle");
	move_and_slide()
