extends Control

@export var seconds_per_tenmins: float = 4.8

@export var morning_texture: Texture2D
@export var afternoon_texture: Texture2D
@export var night_texture: Texture2D

var current_hour: int
var current_minute: int
var current_day: int = 1
var time_accumulator: float = 0.0
var morning: bool = true
var fade_in_progress: bool = false

@onready var clock_label: Label = $ClockLabel
@onready var day_label: Label = $DayLabel
@onready var time_indicator: Sprite2D = $TimeIndicator

# Fade overlay node (ColorRect, covers screen, z_index high)
@onready var fade_rect: ColorRect = $FadeRect

func _ready():
	current_hour = 7
	current_minute = 0
	morning = true
	update_labels()
	update_time_indicator()
	fade_rect.visible = false
	fade_rect.z_index = 100

func _process(delta):
	if fade_in_progress:
		return

	time_accumulator += delta
	if time_accumulator >= seconds_per_tenmins:
		time_accumulator -= seconds_per_tenmins
		current_minute += 10
		if current_minute >= 60:
			current_minute = 0
			current_hour += 1

			# Morning ends at 12:00 PM
			if morning and current_hour == 12 and current_minute == 0:
				morning = false
				update_time_indicator()

			# Day ends at 12:00 AM
			if not morning and current_hour == 0 and current_minute == 0:
				fade_to_next_day()
				return

		update_labels()

func update_labels():
	var suffix = "AM"
	var display_hour = current_hour
	if current_hour == 0:
		display_hour = 12
		suffix = "AM"
	elif current_hour == 12:
		suffix = "PM"
	elif current_hour > 12:
		display_hour = current_hour - 12
		suffix = "PM"
	clock_label.text = "%02d:%02d %s" % [display_hour, current_minute, suffix]
	day_label.text = "Day %d" % current_day

func update_time_indicator():
	if morning:
		time_indicator.texture = morning_texture
	elif current_hour <= 16:
		time_indicator.texture = afternoon_texture
	else:
		time_indicator.texture = night_texture

func fade_to_next_day():
	fade_in_progress = true
	fade_rect.visible = true
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.z_index = 100
	# Fade to black
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 1.0)
	tween.tween_callback(Callable(self, "_show_day_label"))
	tween.tween_interval(1.0)
	tween.tween_callback(Callable(self, "_fade_in_new_day"))

func _show_day_label():
	day_label.visible = true
	day_label.text = "Day: %d" % current_day
	day_label.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(day_label, "modulate", Color(1, 1, 1, 1), 1.0)

func _fade_in_new_day():
	current_day += 1
	current_hour = 7
	current_minute = 0
	morning = true
	update_labels()
	update_time_indicator()
	day_label.text = "Day: %d" % current_day
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 1.0)
	tween.tween_callback(Callable(self, "_end_fade"))

func _end_fade():
	fade_rect.visible = false
	day_label.modulate = Color(1, 1, 1, 1)
	fade_in_progress = false
