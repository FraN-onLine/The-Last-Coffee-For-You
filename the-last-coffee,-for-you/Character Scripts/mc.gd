extends CharacterBody2D

@export var speed := 120.
var paused: bool = false

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var inv: Inventory
@onready var held_item_sprite: Sprite2D = $HeldItemSprite

func set_held_item_texture(texture: Texture2D):
	held_item_sprite.texture = texture
	held_item_sprite.visible = texture != null
	$ItemCollision.disabled = texture == null

func _physics_process(delta):
	if paused:
		return
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	velocity = input_vector * speed
	move_and_slide()

	# Animation logic
	if input_vector != Vector2.ZERO:
		if abs(input_vector.x) > abs(input_vector.y):
			anim_sprite.animation = "walk-side"
			anim_sprite.flip_h = input_vector.x < 0
		elif input_vector.y < 0:
			anim_sprite.animation = "walk-up"
			anim_sprite.flip_h = false
		else:
			anim_sprite.animation = "walk-down"
			anim_sprite.flip_h = false
		anim_sprite.play()
	else:
		anim_sprite.stop()
