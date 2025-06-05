class_name CraftingSlot

extends Node2D

#Goes from left to right then top to bottom
@export var frame : int

@export var slotID : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Sets frame rect based on frame number
	var frameRect = Rect2(frame%4*24,frame/4*24,24,24)
	$Sprite2D.region_rect = frameRect


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
