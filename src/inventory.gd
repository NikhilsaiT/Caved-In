extends Node2D
var inventoryOn = false
var itemData
var itemInHand = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	itemData = []
	itemData.resize(40)
	itemData.fill(Item.new(0,0))
	for slot in get_tree().get_nodes_in_group("slots"):
			if slot.type == 1:
				slot.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	for slot in get_tree().get_nodes_in_group("slots"):
		if(Input.is_action_just_pressed("toggle inventory")): #hides inventory when inventory is not open
			if slot.type == 1:
				if inventoryOn:
					slot.visible = false
				else:
					slot.visible = true
		if slot.visible : #updates item/amount visuals for inventory slots that are visible
			slot.get_node("displayItem/AnimatedSprite2D").frame = itemData[slot.slotID].ID
			if(itemData[slot.slotID].amount > 1):
				slot.get_node("displayItem/AmountDisp").text = str(itemData[slot.slotID].amount)
			else:
				slot.get_node("displayItem/AmountDisp").text = ""
			
		if inventoryOn && Input.is_action_just_pressed("select"): #selects item
			var mPos = get_local_mouse_position()
			var size = Vector2(16,16)
			if isOverInvetorySlot(mPos, Rect2(slot.position.x-size.x/2,slot.position.y-size.y/2,size.x,size.y)):
				itemInHand = itemData[slot.slotID]
				itemData[slot.slotID] = Item.new(0,0)
		if inventoryOn && Input.is_action_just_released("select") && itemInHand != null: #drops item
			var mPos = get_local_mouse_position()
			var size = Vector2(20,20)
			if isOverInvetorySlot(mPos, Rect2(slot.position.x-size.x/2,slot.position.y-size.y/2,size.x,size.y)):
				pickup(itemInHand,slot.slotID)
				itemInHand = null
		
	if(Input.is_action_just_pressed("toggle inventory")): #toggles inventory when E key is pressed
		inventoryOn = !inventoryOn
	
<<<<<<< HEAD
	#if(Input.is_action_just_pressed("right")): #DEBUG: adds 1 iron ingot to inventory (delete later)
		#var rng = RandomNumberGenerator.new()
		#for n in range(100):
			#pickup(Item.new(rng.randi_range(1,4),1),0)
=======
	if(Input.is_action_just_pressed("move_right")): #DEBUG: adds 1 iron ingot to inventory (delete later)
		var rng = RandomNumberGenerator.new()
		pickup(Item.new(rng.randi_range(1,4),1),0)
>>>>>>> 9acbe04a5cd8e5fd9d7f7aa133ca5a6c2364b667
		
	if(itemInHand != null): #Displays the item in hand if an item is being held
		$heldItem.position = get_local_mouse_position()
		$heldItem.visible = true
		$heldItem.get_node("AnimatedSprite2D").frame = itemInHand.ID
		$heldItem.get_node("AmountDisp").text = str(itemInHand.amount)
		if(!Input.is_action_pressed("select")):
			pickup(itemInHand,0)
			itemInHand = null
	else:
		$heldItem.visible = false
		
func pickup(item: Item, startIndex: int) -> void:
	var placeFound = false
	for i in range(startIndex,itemData.size()): #checks if item already exists in inventory
		if(itemData[i].ID == item.ID): 
			if((itemData[i].amount + item.amount) <= Global.ITEM_DATA[item.ID][2]): #checks if it goes over stack limit for that item
				itemData[i].amount += item.amount
				print(itemData[i].amount)
				placeFound = true
				break
			elif(itemData[i].amount < Global.ITEM_DATA[item.ID][2]):
				item.amount -= Global.ITEM_DATA[item.ID][2]-itemData[i].amount #fills to stack then pickup excess
				itemData[i].amount = Global.ITEM_DATA[item.ID][2]
				placeFound = true
				pickup(item,0)
				break
	if(!placeFound): #if place not already found pick the nearest empty spot
		for i in range(startIndex,itemData.size()):
			if(itemData[i].ID == 0):
				itemData[i] = item
				placeFound = true
				break
	if(!placeFound): #code for dropping it if it never finds a palce
		pass
		
func isOverInvetorySlot(mPos: Vector2, slotRect: Rect2) -> bool:
	return (mPos.x > slotRect.position.x && mPos.y > slotRect.position.y && mPos.x < slotRect.position.x+slotRect.size.x && mPos.y < slotRect.position.y+slotRect.size.y)
