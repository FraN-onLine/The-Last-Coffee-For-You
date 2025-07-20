extends Node2D

@export var container_inventory: Inventory # assign unique inventory in editor
const ContainerUI = preload("res://UI/container_ui.tscn")
@onready var Area = $Area2D
var player_nearby := false

func _ready():
	print($Area2D)
	print(Area)
	if $Area2D:
		$Area2D.body_entered.connect(Callable(self, "_on_body_entered"))
		$Area2D.body_exited.connect(Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("sda")
		player_nearby = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_nearby = false

func _input(event):
	if player_nearby and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		open_container_ui()

func open_container_ui():
	print("w")
	var ui = ContainerUI.instantiate()
	ui.container_inventory = container_inventory
	var canvas_layer = get_tree().current_scene.get_node("UI") # Adjust if your CanvasLayer is named differently
	canvas_layer.add_child(ui)
