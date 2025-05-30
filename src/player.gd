extends CharacterBody2D


const ACCEL = 2000.0
const MAX_SPEED = 150.0
const JUMP_VELOCITY = -400.0
var isWalking = false
var chunkPos = Vector2(0,0)

func _physics_process(delta: float) -> void:
	isWalking = false;
	
	# left-right movement
	if Input.is_action_pressed("move_right") && !Input.is_action_pressed("left"):
		velocity.x = min(velocity.x + ACCEL*delta, MAX_SPEED);
		isWalking = true;
		$AnimatedSprite2D.flip_h = false;
	elif Input.is_action_pressed("move_left")  && !Input.is_action_pressed("right"):
		velocity.x = max(velocity.x - ACCEL*delta, MAX_SPEED*-1);
		isWalking = true;
		$AnimatedSprite2D.flip_h = true;
	else:
		if velocity.x > 0:
			velocity.x = max(velocity.x - ACCEL*delta, 0);
		elif velocity.x < 0:
			velocity.x = min(velocity.x + ACCEL*delta, 0);
	
	# up-down movement
	if Input.is_action_pressed("move_down") && !Input.is_action_pressed("up"):
		velocity.y = min(velocity.y + ACCEL*delta, MAX_SPEED);
		isWalking = true;
	elif Input.is_action_pressed("move_up")  && !Input.is_action_pressed("down"):
		velocity.y = max(velocity.y - ACCEL*delta, MAX_SPEED*-1);
		isWalking = true;
	else:
		if velocity.y > 0:
			velocity.y = max(velocity.y - ACCEL*delta, 0);
		elif velocity.y < 0:
			velocity.y = min(velocity.y + ACCEL*delta, 0);
	
	var currChunkPos = Vector2(round(position.x/(Global.CHUNK_SIZE*8)-0.5),round(position.y/(Global.CHUNK_SIZE*8)-0.5))
	var map = get_parent().get_node("TileMap")
	if(currChunkPos != map.current_chunk):
		map.current_chunk = currChunkPos
		map.load_visible_chunks()
		map.unload_far_chunks()
		
		
	
	# animation
	if(isWalking):
		$AnimatedSprite2D.play("run");
	else:
		$AnimatedSprite2D.play("idle");
	move_and_slide()
