extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_area_entered(area: Area2D) -> void:
	if(area.name == "enemy_hitbox"):
		var enemy = area.get_parent()
		enemy.damage_knockback(10, "melee", 200, rad_to_deg(get_parent().angle_of_motion))
