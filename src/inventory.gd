extends Node2D
var inventoryOn = false
var itemData
var is_shift_dragging := false
var dragged_slots := []

func _ready() -> void:
	itemData = []
	itemData.resize(40)
	itemData.fill(Item.new(0, 0))
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.type == 1:
			slot.visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"): #hides/toggles inventory
		inventoryOn = !inventoryOn
		for slot in get_tree().get_nodes_in_group("slots"):
			if slot.type == 1:
				slot.visible = inventoryOn
		for slot in get_tree().get_nodes_in_group("crafting_slots"):
			slot.visible = inventoryOn

	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.visible:
			slot.get_node("displayItem/AnimatedSprite2D").frame = itemData[slot.slotID].ID
			slot.get_node("displayItem/AmountDisp").text = str(itemData[slot.slotID].amount) if itemData[slot.slotID].amount > 1 else ""

	if inventoryOn and Input.is_action_just_pressed("select"): #selects item
		var mPos = get_global_mouse_position()
		var slot = get_slot_under_mouse(mPos, "slots")
		if slot != null:
			Global.itemInHand = itemData[slot.slotID]
			Global.itemSourceSlot = slot.slotID
			itemData[slot.slotID] = Item.new(0, 0)

	if inventoryOn and Input.is_action_just_released("select") and Global.itemInHand != null:
		var mPos = get_global_mouse_position()
		var placed = try_pickup(Global.itemInHand, mPos)
		if not placed:
			var crafting = get_node("/root/world/Player/crafting")
			placed = crafting.try_pickup(Global.itemInHand, mPos)

		if placed:
			Global.itemInHand = null
			Global.itemSourceSlot = null
		elif Global.itemSourceSlot != null:
			itemData[Global.itemSourceSlot] = Global.itemInHand
			Global.itemInHand = null
			Global.itemSourceSlot = null

	if Input.is_action_just_pressed("move_right"): # DEBUG
		var rng = RandomNumberGenerator.new()
		var new_item = Item.new(rng.randi_range(1, 4), 1)

		var placed = false
		for i in itemData.size():
			var slot_item = itemData[i]
			var max_stack = Global.ITEM_DATA[new_item.ID][2]

			if slot_item.ID == 0:
				itemData[i] = new_item
				placed = true
				break
			elif slot_item.ID == new_item.ID and slot_item.amount < max_stack:
				var space = max_stack - slot_item.amount
				if new_item.amount <= space:
					slot_item.amount += new_item.amount
					placed = true
					break
				else:
					slot_item.amount = max_stack
					new_item.amount -= space

	if Global.itemInHand != null: #Displays the item in hand if an item is being held
		$heldItem.position = get_local_mouse_position()
		$heldItem.visible = true
		$heldItem.get_node("AnimatedSprite2D").frame = Global.itemInHand.ID
		$heldItem.get_node("AmountDisp").text = str(Global.itemInHand.amount)
	else:
		$heldItem.visible = false

	handle_shift_drag(delta)

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
	var slot = get_slot_under_mouse(mPos, "slots")
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

func handle_shift_drag(delta: float) -> void:
	if inventoryOn and Input.is_action_pressed("select") and Input.is_action_pressed("shift") and Global.itemInHand != null:
		is_shift_dragging = true
		var mPos = get_global_mouse_position()
		var slot = get_slot_under_mouse(mPos, "slots")

		if slot != null and not dragged_slots.has(slot.slotID):
			var max_stack = Global.ITEM_DATA[Global.itemInHand.ID][2]
			if itemData[slot.slotID].ID == 0 or (itemData[slot.slotID].ID == Global.itemInHand.ID and itemData[slot.slotID].amount < max_stack):
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
