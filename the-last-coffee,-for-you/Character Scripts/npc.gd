extends CharacterBody2D

@export var npc_data: NPCData
@export var speed: float = 80.0
var player_nearby := false
var current_path: Array = []
var path_index: int = 0
var interacted_today: bool = false


func _ready():
	set_daily_schedule()
	play_animation("idle")
	$ProximityArea.body_entered.connect(Callable(self, "_on_proximity_entered"))
	$ProximityArea.body_exited.connect(Callable(self, "_on_proximity_exited"))
	$InteractionArea.input_event.connect(Callable(self, "_on_interaction_area_input"))
	Global.connect("new_day", Callable(self, "new_day"))

func _process(delta: float) -> void:
	if velocity.length() > 0:
		play_animation("walk-right" if velocity.x > 0 else "walk-left")
	elif velocity.y < 0:
		play_animation("walk-up")
	elif velocity.y > 0:
		play_animation("walk-down")
	else:
		play_animation("walk-right")
	

func new_day():
	# Reset interaction state for the new day
	print("new day for NPC: ", npc_data.name)
	interacted_today = false
	set_daily_schedule()

func set_daily_schedule():
	var day = get_current_day()
	if npc_data and npc_data.schedule.has(day):
		current_path = npc_data.schedule[day]
		path_index = 0

func _physics_process(delta):
	if current_path.size() > 0 and path_index < current_path.size():
		var target = current_path[path_index]
		var direction = (target - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		play_animation("walk-right")
		if global_position.distance_to(target) < 5:
			path_index += 1
	else:
		velocity = Vector2.ZERO
		play_animation("idle-right")

func _on_interaction_area_input(viewport, event, shape_idx):
	if player_nearby and event.is_action_pressed("interact") and not interacted_today:
		interact_with_npc()
		interacted_today = true

func interact_with_npc():
	var inv_ui = get_tree().get_first_node_in_group("inventory_ui")
	if inv_ui:
		var inv = inv_ui.inv
		var slot_index = inv_ui.selected_index
		var slot = inv.slots[slot_index]
		if slot.item:
			var item = slot.item
			var reaction_key = "neutral"
			if npc_data.loved_items.has(item):
				reaction_key = "liked"
			elif npc_data.hated_items.has(item):
				reaction_key = "hated"
			# Remove the item from the inventory
			inv.remove_one_from_slot(slot_index)
			inv_ui.update_slots()
			# Show reaction dialogue using Dialogue Manager
			DialogueManager.show_dialogue_balloon(npc_data.dialogue_path, reaction_key)
			Global.is_paused = true
			DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
			return
	# Normal
	DialogueManager.show_dialogue_balloon(npc_data.dialogue_path, "start")
	Global.is_paused = true
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended():
	Global.is_paused = false
	if DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)

func play_animation(anim_type: String):
	if npc_data and npc_data.animations.has(anim_type):
		$AnimatedSprite2D.play(npc_data.animations[anim_type])

func get_current_day():
	var time_ui = get_tree().current_scene.get_node("UI/TimeUI")
	if time_ui:
		return Global.current_day # returns an int
	return 1

func reset_interaction():
	interacted_today = false

func _on_proximity_entered(body):
	if body.is_in_group("player"):
		player_nearby = true

func _on_proximity_exited(body):
	if body.is_in_group("player"):
		player_nearby = false
