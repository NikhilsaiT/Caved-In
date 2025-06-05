class_name weapon_hitbox

extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if(area.name == "enemy_hitbox"):
		var enemy = area.get_parent()
		enemy.damage_knockback(10, "melee", 200, rad_to_deg(atan2(enemy.position.y-get_parent().get_parent().position.y,enemy.position.x-get_parent().get_parent().position.x)))
