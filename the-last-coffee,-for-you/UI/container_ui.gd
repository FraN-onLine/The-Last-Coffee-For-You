extends Control

@export var container_inventory: Inventory
@onready var container_slots: Array = $NinePatchRect/GridContainer.get_children()
const PopupText = preload("res://Interactables/pop_up_text.tscn")

var player_inventory: Inventory = null
var player_slots: Array = []
var player_selected_index: int = 0

func _ready():
	# Find player and their inventory
	var player = get_tree().get_first_node_in_group("player")
	if player.inv:
		player_inventory = player.inv
		# Assuming player's inventory UI is always present
		var inv_ui = get_tree().get_first_node_in_group("inventory_ui")
		if inv_ui:
			player_slots = inv_ui.slots
			player_selected_index = inv_ui.selected_index
	update_slots()

func update_slots():
	for i in range(min(container_inventory.slots.size(), container_slots.size())):
		container_slots[i].update(container_inventory.slots[i])
	for slot in container_slots:
		slot.modulate = Color(1, 1, 1, 1)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		# Check if clicking on container slot
		for i in range(container_slots.size()):
			if container_slots[i].get_global_rect().has_point(mouse_pos):
				transfer_item_from_player_to_container(i)
				return
		# Check if clicking on player inventory slot
		if player_slots:
			for i in range(player_slots.size()):
				if player_slots[i].get_global_rect().has_point(mouse_pos):
					transfer_item_from_container_to_player(i)
					return

func transfer_item_from_player_to_container(container_index):
	if not player_inventory:
		show_popup("No player inventory found!")
		return
	var player_selected = get_player_selected_index()
	var player_slot = player_inventory.slots[player_selected]
	var container_slot = container_inventory.slots[container_index]
	if player_slot.item == null:
		return
	if container_slot.item == null:
		container_slot.item = player_slot.item
		container_slot.amount = player_slot.amount
		player_slot.item = null
		player_slot.amount = 0
		update_slots()
		update_player_ui()
	elif container_slot.item == player_slot.item:
		container_slot.amount += player_slot.amount
		player_slot.item = null
		player_slot.amount = 0
		update_slots()
		update_player_ui()
	else:
		show_popup("Chest full!")

func transfer_item_from_container_to_player(player_index):
	if not player_inventory:
		show_popup("No player inventory found!")
		return
	var container_selected = get_container_selected_index()
	var container_slot = container_inventory.slots[container_selected]
	var player_slot = player_inventory.slots[player_index]
	if container_slot.item == null:
		return
	if player_slot.item == null:
		player_slot.item = container_slot.item
		player_slot.amount = container_slot.amount
		container_slot.item = null
		container_slot.amount = 0
		update_slots()
		update_player_ui()
	elif player_slot.item == container_slot.item:
		player_slot.amount += container_slot.amount
		container_slot.item = null
		container_slot.amount = 0
		update_slots()
		update_player_ui()
	else:
		show_popup("Inventory full!")

func get_player_selected_index():
	# Try to get selected_index from inventory UI group
	var inv_ui = get_tree().get_first_node_in_group("inventory_ui")
	if inv_ui:
		return inv_ui.selected_index
	return 0

func get_container_selected_index():
	# You can implement selection logic for container if needed
	return 0

func update_player_ui():
	var inv_ui = get_tree().get_first_node_in_group("inventory_ui")
	if inv_ui:
		inv_ui.update_slots()

func show_popup(text):
	var popup = PopupText.instantiate()
	add_child(popup)
	popup.global_position = get_global_mouse_position()
	popup.show_popup(text)
