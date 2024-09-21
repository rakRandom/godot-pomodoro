extends Control

@onready var streak_label = %StreakLabel
@onready var current_stage_label = %CurrentStageLabel
@onready var reset_button = %ResetButton

@onready var cycle_progress_bar = %CycleProgressBar

@onready var timer_label = %TimerLabel
@onready var progress_bar = %ProgressBar
@onready var main_button = %MainButton
@onready var config_button = %ConfigButton
@onready var config_panel = %ConfigPanel

@onready var focus_input = %FocusInput
@onready var long_input = %LongInput
@onready var short_input = %ShortInput

@onready var beep_sound = %BeepSound
@onready var tick_sound = %TickSound

enum Stage {
	FOCUS,
	LONG,
	SHORT
}

var stage_times = {
	"focus": 25 * 60,
	"long": 15 * 60,
	"short": 5 * 60
};

var cycle_level = 0
var current_stage = 0
var is_running = false
var lapsed_time = 0
var timer_time = 0
var streak_time = 0


func select_stage(stage: Stage):
	match stage:
		Stage.FOCUS:
			current_stage = stage_times["focus"]
			current_stage_label.text = "Focus on your goals"
		Stage.LONG:
			current_stage = stage_times["long"]
			current_stage_label.text = "Take a good break"
		Stage.SHORT:
			current_stage = stage_times["short"]
			current_stage_label.text = "Rest a bit"
		_:
			return
	
	timer_time = current_stage
	progress_bar.max_value = current_stage
	lapsed_time = Time.get_ticks_msec()
	update_timer()


func next_stage():
	match cycle_level:
		-1:
			select_stage(Stage.FOCUS)
		0:
			select_stage(Stage.SHORT)
		1:
			select_stage(Stage.FOCUS)
		2:
			select_stage(Stage.SHORT)
		3:
			select_stage(Stage.FOCUS)
		4:
			select_stage(Stage.SHORT)
		5:
			select_stage(Stage.FOCUS)
		6:
			select_stage(Stage.LONG)
		7:
			select_stage(Stage.FOCUS)
			cycle_level = -1
		_:
			return
	
	cycle_level += 1
	
	var tween = get_tree().create_tween()
	tween.tween_property(cycle_progress_bar, "value", cycle_level * 10, 0.5)


func _ready():
	select_stage(Stage.FOCUS)


func _process(_delta):
	if is_running:
		if Time.get_ticks_msec() - lapsed_time > 1000:
			tick_sound.play()
			
			timer_time -= 1
			streak_time += 1
			update_timer()
			
			if timer_time <= 0:
				next_stage()
				# beep_sound.play()
			
			lapsed_time = Time.get_ticks_msec()


func _on_main_button_pressed():
	if is_running:
		is_running = false
		streak_time = 0
		if timer_time == current_stage:
			main_button.text = "Start"
		else:
			main_button.text = "Continue"
	else:
		is_running = true
		main_button.text = "Pause"
		lapsed_time = Time.get_ticks_msec()
	update_timer()


func _on_reset_button_pressed():
	cycle_level = -1
	next_stage()
	is_running = false
	main_button.text = "Start"


func _on_config_button_pressed():
	config_panel.visible = not config_panel.visible


func update_timer():
	var tween = get_tree().create_tween()
	tween.tween_property(progress_bar, "value", current_stage - timer_time, 0.25)
	timer_label.text = "%02d:%02d" % [timer_time / 60, timer_time % 60]
	streak_label.text = "Streak: %02d:%02d" % [streak_time / 60, streak_time % 60]


func _on_save_button_pressed():
	stage_times["focus"] = int(focus_input.value * 60)
	stage_times["long"] = int(long_input.value * 60)
	stage_times["short"] = int(short_input.value * 60)


func _on_reset_default_button_pressed():
	focus_input.value = 25
	long_input.value = 15
	short_input.value = 5
	
	stage_times["focus"] = int(focus_input.value * 60)
	stage_times["long"] = int(long_input.value * 60)
	stage_times["short"] = int(short_input.value * 60)
