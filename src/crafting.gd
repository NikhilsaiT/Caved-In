extends Node2D

var craftingOn = false
var itemData
var is_shift_dragging := false
var dragged_slots := []

func _ready() -> void:
	itemData = []
	itemData.resize(5) # 4 input + 1 result
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

	if craftingOn and Input.is_action_just_pressed("select"):
		var mPos = get_global_mouse_position()
		var slot = get_slot_under_mouse(mPos, "crafting_slots")

		if slot != null:
			if slot.slotID == 4 and itemData[4].ID != 0:
				Global.itemInHand = itemData[4]
				Global.itemSourceSlot = null
				itemData[4] = Item.new(0, 0)

				for recipe in Global.CRAFTING_RECIPES:
					if recipe_matches(recipe):
						consume_pattern(recipe)
						break
				check_crafting()

			elif Global.itemInHand == null:
				Global.itemInHand = itemData[slot.slotID]
				Global.itemSourceSlot = slot.slotID
				itemData[slot.slotID] = Item.new(0, 0)

	if craftingOn and Input.is_action_just_released("select") and Global.itemInHand != null:
		var mPos = get_global_mouse_position()
		var placed = try_pickup(Global.itemInHand, mPos)
		if not placed:
			var inventory = get_node("/root/world/Player/Inventory")
			placed = inventory.try_pickup(Global.itemInHand, mPos)

		if placed:
			Global.itemInHand = null
			Global.itemSourceSlot = null
		elif Global.itemSourceSlot != null:
			itemData[Global.itemSourceSlot] = Global.itemInHand
			Global.itemInHand = null
			Global.itemSourceSlot = null

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

	if slot != null and slot.has_method("get"):
		if "slotID" in slot and slot.slotID >= 0 and slot.slotID < itemData.size():
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
	for recipe in Global.CRAFTING_RECIPES:
		if recipe_matches(recipe):
			itemData[4] = recipe["result"].clone()
			matched = true
			break

	if not matched:
		itemData[4] = Item.new(0, 0)

func recipe_matches(recipe: Dictionary) -> bool:
	var pattern = recipe["pattern"]
	var pattern_size = Vector2(len(pattern[0]), len(pattern))

	var grid_ids = [
	[itemData[0].ID, itemData[1].ID],
	[itemData[2].ID, itemData[3].ID]
]

	for y_off in range(3 - int(pattern_size.y)):
		for x_off in range(3 - int(pattern_size.x)):
			if pattern_fits_at(grid_ids, pattern, x_off, y_off):
				return true
	return false

func pattern_fits_at(grid: Array, pattern: Array, x_off: int, y_off: int) -> bool:
	for y in range(len(pattern)):
		for x in range(len(pattern[0])):
			var pattern_val = pattern[y][x]
			if pattern_val == 0:
				continue
			if grid[y + y_off][x + x_off] != pattern_val:
				return false
	return true

func consume_pattern(recipe: Dictionary):
	var pattern = recipe["pattern"]
	var pattern_size = Vector2(len(pattern[0]), len(pattern))

	var grid_ids = [
	[itemData[0].ID, itemData[1].ID],
	[itemData[2].ID, itemData[3].ID]
]


	for y_off in range(3 - int(pattern_size.y)):
		for x_off in range(3 - int(pattern_size.x)):
			if pattern_fits_at(grid_ids, pattern, x_off, y_off):
				for y in range(len(pattern)):
					for x in range(len(pattern[0])):
						var id_to_remove = pattern[y][x]
						if id_to_remove != 0:
							var index = (y + y_off) * 2 + (x + x_off)
							itemData[index].amount -= 1
							if itemData[index].amount <= 0:
								itemData[index] = Item.new(0, 0)
				break

func handle_shift_drag(delta: float) -> void:
	if craftingOn and Input.is_action_pressed("select") and Input.is_action_pressed("shift") and Global.itemInHand != null:
		is_shift_dragging = true
		var mPos = get_global_mouse_position()
		var slot = get_slot_under_mouse(mPos, "crafting_slots")

		if slot != null and not dragged_slots.has(slot.slotID) and slot.slotID < 4:
			var max_stack = Global.ITEM_DATA[Global.itemInHand.ID][2]
			if itemData[slot.slotID].ID == 0 or (itemData[slot.slotID].ID == Global.itemInHand.ID):
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
