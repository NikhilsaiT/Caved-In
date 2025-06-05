extends Node2D

func set_item(item):
	var display = get_node_or_null("displayItem")
	if display == null:
		print("Error: 'DisplayItem' node not found!")
		return
	
	var sprite = display.get_node_or_null("AnimatedSprite2D")
	var label = display.get_node_or_null("Amou")
	
	if sprite == null or label == null:
		print("Error: 'AnimatedSprite2D' or 'Label' node not found inside DisplayItem!")
		return
	
	if item != null:
		sprite.frame = item.ID
		if item.amount > 1:
			label.text = str(item.amount)
		else:
			label.text = ""
	else:
		sprite.frame = -1
		label.text = ""
