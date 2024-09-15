extends Control

@onready var idle = %Idle
@onready var start = %Start
@onready var input = %Input
@onready var plus = %Plus
@onready var minus = %Minus
@onready var streak = %Streak
@onready var running = %Running
@onready var stop = %Stop
@onready var time = %Time
@onready var beep = %Beep
@onready var tick = %Tick


var original_time = 0
var timer_time = 0
var streak_time = 0
var current_time = 0.0

var is_running = false
var is_beeping = false


func _ready():
	stop_timer()
	add_time(1800)
	current_time = Time.get_ticks_msec()


func _process(_delta):
	if is_running:
		if Time.get_ticks_msec() - current_time > 1000 and not is_beeping:
			add_time(-1)
		
			if timer_time <= 0:
				streak_time += original_time
				beep.play()
				is_beeping = true
			else:
				tick.play()
			
			current_time = Time.get_ticks_msec()


func _on_start_pressed():
	if timer_time <= 0:
		return
	idle.visible = false
	running.visible = true
	is_running = true
	original_time = timer_time
	current_time = Time.get_ticks_msec()


func _on_plus_pressed():
	add_time(min(int(input.text), 5999 - timer_time))


func _on_minus_pressed():
	add_time(-min(int(input.text), timer_time))


func _on_stop_pressed():
	if timer_time > 0:
		streak_time = 0
	timer_time = original_time
	update_timer()
	stop_timer()


func stop_timer():
	beep.stop()
	is_beeping = false
	is_running = false
	running.visible = false
	idle.visible = true
	update_streak()


func add_time(time_to_add: int):
	if timer_time + time_to_add > 5999 or timer_time + time_to_add < 0 or time_to_add == 0:
		return
	
	timer_time += time_to_add
	update_timer()


func update_timer():
	time.text = "%02d:%02d" % [timer_time / 60, timer_time % 60]


func update_streak():
	streak.text = "Time Streak: %d minutes and %d seconds" % [streak_time / 60, streak_time % 60]
