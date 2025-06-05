class_name Item

extends Node

@export var ID : int :
	set(value):
		ID = value
		itemName = Global.ITEM_DATA[ID][1]
		itemClass = Global.ITEM_DATA[ID][5]
@export var amount : int
var itemName = ""
var itemClass = ""

func _init(id: int, amt: int) -> void:
	ID = id
	amount = amt

func getID() -> int:
	return ID
	
func clone():
	return Item.new(self.ID, self.amount)
