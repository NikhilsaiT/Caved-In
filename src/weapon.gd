class_name weapon

extends StaticBody2D

@export var weapon_name: String
@export var weapon_type: String
@export var swing_angle: float
@export var lifetime: float
@export var damage: int = 0
var init_angle = 0.0 #angle to start at (used for calculations)
var lifetime_left = 0.0
var comeback = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lifetime_left = lifetime
	if weapon_type == "sword":
		swing_angle = deg_to_rad(swing_angle)
		init_angle = atan2(get_local_mouse_position().y-position.y,get_local_mouse_position().x-position.x)-(swing_angle/2.0)
		
	if weapon_type == "greatsword":
		swing_angle = deg_to_rad(swing_angle)
		init_angle = atan2(get_local_mouse_position().y-position.y,get_local_mouse_position().x-position.x)-(swing_angle/2.0)
		
	if weapon_type == "spear":
		init_angle = atan2(get_local_mouse_position().y-position.y,get_local_mouse_position().x-position.x)
		rotation = init_angle
	if weapon_type == "dagger":
		init_angle = atan2(get_local_mouse_position().y-position.y,get_local_mouse_position().x-position.x)
		rotation = init_angle
	if weapon_type == "hammer":
		init_angle = atan2(get_local_mouse_position().y-position.y,get_local_mouse_position().x-position.x)-(swing_angle/2.0)
		swing_angle = deg_to_rad(swing_angle)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if weapon_type == "sword":
		rotation = init_angle+(swing_angle*(1-(lifetime_left/lifetime)))
		if(lifetime_left < 0):
			queue_free()
	if weapon_type == "hammer":
		var ang = 0.0
		var time = 1-(lifetime_left/lifetime)
		var s = 1.70158 #overshoot value
		if(time < 0.5):
			ang = 0.5 * (pow(2*time,2)*((s+1)*2*time-s))
		else:
			ang = 0.5 * (pow(2*time-2,2)*((s+1)*(2*time-2)+s)+2)
		rotation = init_angle+(swing_angle*ang)
		if(lifetime_left < 0):
			queue_free()
	if weapon_type == "greatsword":
		#var time = 1-(lifetime_left/lifetime)
		#var ang = -0.5*(cos(PI*time)-1)
		var time = 1-(lifetime_left/lifetime)
		var ang = -0.5*(cos(PI*time)-1)
		if(time == 0.0):
			ang = 0.0
		elif(time < 0.5):
			ang = 0.5*pow(2,20*time-10)
		elif(time >= 0.5 && time != 1.0):
			ang = 1-0.5*pow(2,-20*time+10)
		else:
			ang = 1.0
		rotation = init_angle+(swing_angle*(ang))
		if(lifetime_left < 0):
			queue_free()
	if weapon_type == "spear":
		if !comeback:
			position = Vector2(swing_angle*(1-(lifetime_left/lifetime))*cos(init_angle),swing_angle*(1-(lifetime_left/lifetime))*sin(init_angle))
			if(lifetime_left < 0):
				comeback = true
				lifetime_left = lifetime
		else:
			position = Vector2(swing_angle*cos(init_angle)-swing_angle*(1-(lifetime_left/lifetime))*cos(init_angle),swing_angle*sin(init_angle)-swing_angle*(1-(lifetime_left/lifetime))*sin(init_angle))
			if(lifetime_left < 0):
				queue_free()
	if weapon_type == "dagger":
		position = Vector2(swing_angle*(1-(lifetime_left/lifetime))*cos(init_angle),swing_angle*(1-(lifetime_left/lifetime))*sin(init_angle))
		if(lifetime_left < 0):
			queue_free()
	get_node("weapon_hitbox/CollisionShape2D").disabled = false
	
	lifetime_left -= delta
	
	
