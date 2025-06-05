extends Node

#Item data format: [0: ID, 1: name, 2: max stack, 3: type[EX: material, weapon, tool], 4: description, 5: class, 6: durability, 7: more info(how to get it)]
#Note: description, class, and durability sections only have to be filled out for non-materials Eg. tools, weapons, consumables
#Format for "more info" section:
#For any material that is dropped from a block write Obtained from...
#For any material that is dropped from an enemy write Drops from...
#For any material that is crafted write crafted in/on...
#Note: if a material has more than one way to obtain it just write the most common way to obtain it
const ITEM_DATA = [
	[0,"empty",0,"material","","",0,""],
	[0,"stone",9999,"material","","",0,"Obtained from rocks in cave layer."],
	[0,"crude iron cluster",9999,"material","","",0,"Obtained from ore clusters in cave layer."],
	[0,"iron ingot",9999,"material","","",0,"Crafted in furnace."],
	[0,"plant fiber",9999,"material","","",0,"Obtained from lichen mats in cave layer."],
	]
	
var itemInHand: Item = null

# In Global.gd, add:

func is_over_any_slot(mPos: Vector2) -> Dictionary:
	var groups = ["slots", "crafting_slots"]
	for group_name in groups:
		for slot in get_tree().get_nodes_in_group(group_name):
			var size = Vector2(20, 20)
			var rect = Rect2(slot.position - size / 2, size)
			if rect.has_point(mPos):
				var slot_type = ""
				if group_name == "slots":
					slot_type = "inventory"
				else:
					slot_type = "crafting"
				return {
					"slot": slot,
					"type": slot_type
				}
	return {}


func pickup(item: Item, startIndex: int, itemData: Array) -> void:
	var placeFound = false
	for i in range(startIndex, itemData.size()):
		if itemData[i].ID == item.ID:
			if itemData[i].amount + item.amount <= Global.ITEM_DATA[item.ID][2]:
				itemData[i].amount += item.amount
				placeFound = true
				break
			elif itemData[i].amount < Global.ITEM_DATA[item.ID][2]:
				item.amount -= Global.ITEM_DATA[item.ID][2] - itemData[i].amount
				itemData[i].amount = Global.ITEM_DATA[item.ID][2]
				placeFound = true
				pickup(item, 0, itemData)
				break
	if not placeFound:
		for i in range(startIndex, itemData.size()):
			if itemData[i].ID == 0:
				itemData[i] = item
				placeFound = true
				break
	if not placeFound:
		# Drop item in world, or ignore
		pass
