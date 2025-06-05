extends CharacterBody2D

var weight = 1000

var health = 100
var weapon_hitbox = load("res://src/weapon_hitbox.gd")
signal enemy_hit(damage,type)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("enemy_hit",_on_enemy_hit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var angle_of_velocity = atan2(velocity.y,velocity.x)
	var magnitude_of_velocity = max(sqrt(pow(velocity.x,2)+pow(velocity.y,2))-weight*delta,0)
	velocity.x = (magnitude_of_velocity)*cos(angle_of_velocity)
	velocity.y = (magnitude_of_velocity)*sin(angle_of_velocity)
	move_and_slide()
	pass
	
func _on_enemy_hit(damage: int, type: String):
	health -= damage
	print(damage)

func damage(damage: int, type: String):
	health -= damage
	if(health <= 0):
		queue_free()
		
func damage_knockback(damage: int, type: String, knockback: int, knockback_ang: float):
	velocity.x = knockback*cos(deg_to_rad(knockback_ang))
	velocity.y = knockback*sin(deg_to_rad(knockback_ang))
	damage(damage,type)
