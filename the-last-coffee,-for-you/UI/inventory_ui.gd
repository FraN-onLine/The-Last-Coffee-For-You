extends Control

@onready var inv = preload("res://Inventory/playerinventory.tres")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()
@onready var player = get_tree().get_first_node_in_group("player")
var selected_index: int = 0


func _ready() -> void:
	update_slots()
	highlight_selected()

func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

	for slot in slots:
		slot.modulate = Color(1, 1, 1, 1)
	highlight_selected()

func update_held_item():
	var item = inv.slots[selected_index].item
	if item and item.texture:
		player.set_held_item_texture(item.texture)
		
	else:
		player.set_held_item_texture(null)

func highlight_selected():
	for i in range(slots.size()):
		if i == selected_index:
			slots[i].modulate = Color(1, 1, 0.7, 1) # yellow tint
			slots[i].show_name()
		else:
			slots[i].modulate = Color(1, 1, 1, 1)
	update_held_item()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			selected_index = (selected_index - 1) % slots.size()
			if selected_index < 0:
				selected_index = 7
			highlight_selected()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			selected_index = abs((selected_index + 1) % slots.size())
			highlight_selected()
