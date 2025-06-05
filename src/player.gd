extends CharacterBody2D


const ACCEL = 2000.0
const MAX_SPEED = 150.0
const JUMP_VELOCITY = -400.0
var isWalking = false
var chunkPos = Vector2(0,0)
var weapons = preload("res://src/weapon_repository.tscn").instantiate()
var projectiles = preload("res://src/projectile_repository.tscn").instantiate()
var equippedWeapon = "stone_greatsword"
var currWeapon
var player_projectiles = []
var left_right = false #alternates fists for gauntlet weapons

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
	
	# attacking
	if Input.is_action_pressed("select"):
		if($weapon_delay.is_stopped()):
			if(equippedWeapon.contains("sword")||equippedWeapon.contains("spear")||equippedWeapon.contains("dagger")||equippedWeapon.contains("hammer")):
				$weapon_delay.start(1.2)
				currWeapon = weapons.get_node(equippedWeapon).duplicate()
				currWeapon.position.x = 0;
				currWeapon.position.y = 0;
				add_child(currWeapon)
			elif(equippedWeapon.contains("gauntlets")):
				$weapon_delay.start(0.1)
				player_projectiles.append(projectiles.get_node("punch").duplicate())
				get_parent().add_child(player_projectiles[player_projectiles.size()-1])
				player_projectiles[player_projectiles.size()-1].angle_of_motion = atan2(get_global_mouse_position().y-position.y,get_global_mouse_position().x-position.x)
				player_projectiles[player_projectiles.size()-1].rotation = player_projectiles[player_projectiles.size()-1].angle_of_motion
				if left_right:
					player_projectiles[player_projectiles.size()-1].position.x = position.x+4*cos(player_projectiles[player_projectiles.size()-1].angle_of_motion-(PI/2.0))
					player_projectiles[player_projectiles.size()-1].position.y = position.y+4*sin(player_projectiles[player_projectiles.size()-1].angle_of_motion-(PI/2.0))
				else:
					player_projectiles[player_projectiles.size()-1].position.x = position.x+4*cos(player_projectiles[player_projectiles.size()-1].angle_of_motion+(PI/2.0))
					player_projectiles[player_projectiles.size()-1].position.y = position.y+4*sin(player_projectiles[player_projectiles.size()-1].angle_of_motion+(PI/2.0))
				left_right = !left_right
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
	
	
	#destroying used up projectiles
	for i in range(player_projectiles.size()-1):
		if player_projectiles[i] == null:
			player_projectiles.pop_at(i)
		else:
			i += 1
