extends CanvasLayer

@export var start_hour: int = 7
@export var end_hour: int = 14
@export var seconds_per_tenmins: float = 5.1 # 1 in-game minute = 0.5 real seconds

var current_hour: int
var current_minute: int
var current_day: int = 1
var time_accumulator: float = 0.0

@onready var clock_label: Label = $ClockLabel
@onready var day_label: Label = $DayLabel

func _ready():
	current_hour = start_hour
	current_minute = 0
	update_labels()

func _process(delta):
	time_accumulator += delta
	if time_accumulator >= seconds_per_tenmins:
		time_accumulator -= seconds_per_tenmins
		current_minute += 10
		if current_minute >= 60:
			current_minute = 0
			current_hour += 1
			if current_hour > end_hour:
				next_day()
		update_labels()

func update_labels():
	clock_label.text = "Time: %02d:%02d" % [current_hour, current_minute]
	day_label.text = "Day: %d" % current_day

func next_day():
	current_day += 1
	current_hour = start_hour
	current_minute = 0
	# You can add more logic here (e.g., reset player, events, etc.)
