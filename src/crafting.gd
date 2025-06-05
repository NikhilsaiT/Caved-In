extends Node2D

var craftingOn = false
var itemData
var is_shift_dragging := false
var dragged_slots := []

# Each recipe defines input IDs and a resulting Item (cloned when applied)
# Recipes with required orientation
var RECIPES = [
	{ "inputs": [1, 2], "result": Item.new(3, 1), "orientation": "horizontal" },
]

func _ready() -> void:
	itemData = []
	itemData.resize(10) # 9 input + 1 result
	for i in range(itemData.size()):
		itemData[i] = Item.new(0, 0)

	for slot in get_tree().get_nodes_in_group("crafting_slots"):
		slot.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		craftingOn = !craftingOn
		for slot in get_tree().get_nodes_in_group("crafting_slots"):
			slot.visible = craftingOn

	for slot in get_tree().get_nodes_in_group("crafting_slots"):
		if slot.visible:
			var item = itemData[slot.slotID]
			if item != null:
				slot.get_node("displayItem/AnimatedSprite2D").frame = item.ID
				slot.get_node("displayItem/AmountDisp").text = str(item.amount) if item.amount > 1 else ""
			else:
				slot.get_node("displayItem/AnimatedSprite2D").frame = 0
				slot.get_node("displayItem/AmountDisp").text = ""
	
	handle_shift_drag(delta)

	# Handle picking up from result slot and consuming ingredients
	if craftingOn and Input.is_action_just_pressed("select"):
		var mPos = get_global_mouse_position()
		var slot = get_slot_under_mouse(mPos, "crafting_slots")

		if slot != null:
			# Handle result slot (crafting output)
			if slot.slotID == 9 and itemData[9].ID != 0:
				Global.itemInHand = itemData[9]
				itemData[9] = Item.new(0, 0)

				# Consume ingredients
				for recipe in RECIPES:
					var expected = recipe["inputs"].duplicate()
					expected.sort()
					var current = []
					for i in range(0, 9):
						if itemData[i].ID != 0:
							current.append(itemData[i].ID)
					current.sort()

					if current == expected:
						for id in recipe["inputs"]:
							for i in range(0, 9):
								if itemData[i].ID == id and itemData[i].amount > 0:
									itemData[i].amount -= 1
									if itemData[i].amount <= 0:
										itemData[i] = Item.new(0, 0)
									break
						break
				check_crafting()

			# Handle regular slot interaction (slotID 0–8)
			elif Global.itemInHand == null:
				Global.itemInHand = itemData[slot.slotID]
				itemData[slot.slotID] = Item.new(0, 0)


	if craftingOn and Input.is_action_just_released("select") and Global.itemInHand != null:
		var mPos = get_global_mouse_position()
		var placed = try_pickup(Global.itemInHand, mPos)
		if not placed:
			var inventory = get_node("/root/world/Player/Inventory")
			placed = inventory.try_pickup(Global.itemInHand, mPos)
		if placed:
			Global.itemInHand = null

	if Global.itemInHand != null:
		$heldItem.position = get_local_mouse_position()
		$heldItem.visible = true
		$heldItem.get_node("AnimatedSprite2D").frame = Global.itemInHand.ID
		$heldItem.get_node("AmountDisp").text = str(Global.itemInHand.amount)
	else:
		$heldItem.visible = false

	check_crafting()

func pickup(item: Item, slot_id: int) -> void:
	var existing = itemData[slot_id]
	var max_stack = Global.ITEM_DATA[item.ID][2]

	if existing.ID == item.ID:
		var space = max_stack - existing.amount
		if space >= item.amount:
			existing.amount += item.amount
			return
		else:
			existing.amount = max_stack
			item.amount -= space
	elif existing.ID == 0:
		itemData[slot_id] = item
		return

	for i in itemData.size():
		if itemData[i].ID == item.ID and itemData[i].amount < max_stack:
			var room = max_stack - itemData[i].amount
			if item.amount <= room:
				itemData[i].amount += item.amount
				return
			else:
				item.amount -= room
				itemData[i].amount = max_stack

func try_pickup(item: Item, mPos: Vector2) -> bool:
	var slot = get_slot_under_mouse(mPos, "crafting_slots")
	if slot != null:
		pickup(item, slot.slotID)
		return true
	return false

func get_slot_under_mouse(mPos: Vector2, group_name: String) -> Node:
	for slot in get_tree().get_nodes_in_group(group_name):
		var size = Vector2(20, 20)
		var slot_rect = Rect2(slot.get_global_position() - size / 2, size)
		if slot_rect.has_point(mPos):
			return slot
	return null

func check_crafting():
	var matched = false
	for recipe in RECIPES:
		if recipe_matches(recipe):
			itemData[9] = recipe["result"].clone()
			matched = true
			break

	if not matched:
		itemData[9] = Item.new(0, 0)

func recipe_matches(recipe: Dictionary) -> bool:
	var inputs = recipe["inputs"].duplicate()
	inputs.sort()

	var found := false

	if recipe["orientation"] == "horizontal":
		for y in range(3):  # Rows
			for x in range(2):  # Columns
				var i1 = y * 3 + x
				var i2 = i1 + 1
				var pair = [itemData[i1].ID, itemData[i2].ID]
				if pair == inputs:
					found = true
					break
			if found:
				break
	elif recipe["orientation"] == "vertical":
		for x in range(3):  # Columns
			for y in range(2):  # Rows
				var i1 = y * 3 + x
				var i2 = (y + 1) * 3 + x
				var pair = [itemData[i1].ID, itemData[i2].ID]
				if pair == inputs:
					found = true
					break
			if found:
				break

	return found

func handle_shift_drag(delta: float) -> void:
	if craftingOn and Input.is_action_pressed("select") and Input.is_action_pressed("shift") and Global.itemInHand != null:
		is_shift_dragging = true
		var mPos = get_global_mouse_position()
		var slot = get_slot_under_mouse(mPos, "crafting_slots")

		if slot != null and not dragged_slots.has(slot.slotID):
			var max_stack = Global.ITEM_DATA[Global.itemInHand.ID][2]
			if itemData[slot.slotID].ID == 0 or (itemData[slot.slotID].ID == Global.itemInHand.ID and itemData[slot.slotID].amount < max_stack):
				# Place one item
				if Global.itemInHand.amount > 1:
					if itemData[slot.slotID].ID == 0:
						itemData[slot.slotID] = Item.new(Global.itemInHand.ID, 1)
					else:
						itemData[slot.slotID].amount += 1
					Global.itemInHand.amount -= 1
					dragged_slots.append(slot.slotID)
	else:
		if is_shift_dragging:
			is_shift_dragging = false
			dragged_slots.clear()
