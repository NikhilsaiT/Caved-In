extends CharacterBody2D

@export var proj_name: String
@export var damage: int
@export var damage_type: String
@export var speed: float
@export var lifetime: float
@export var acceleration: float
var angle_of_motion = 0.0
var lifetime_left

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lifetime_left = lifetime


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var hitbox = get_node("projectile_hitbox/CollisionShape2D")
	hitbox.disabled = false
	
	velocity.x = (speed)*cos(angle_of_motion)
	velocity.y = (speed)*sin(angle_of_motion)
	angle_of_motion = atan2(velocity.y,velocity.x)
	speed = max(sqrt(pow(velocity.x,2)+pow(velocity.y,2))+acceleration*delta,0)
	move_and_slide()
	
	lifetime_left -= delta
	if lifetime_left < 0.0:
		queue_free()
	pass
	
