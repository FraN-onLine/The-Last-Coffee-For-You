extends Panel

@onready var itemDisplay = $CenterContainer/Panel/itemDisplay

func update(Item: Inventory_Item):
	if !Item:
		itemDisplay.visible = false
	else:
		itemDisplay.visible = true
		itemDisplay.texture = Item.texture
