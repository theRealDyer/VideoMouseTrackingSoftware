extends Control

# Get references to button nodes & Video node
@onready var videoPlayer = $VideoStreamPlayer
@onready var start = $Start
@onready var stop = $Stop
@onready var loop = $Loop

func _ready():
	# Linking signals 
	videoPlayer.connect("finished", _show_load_button)
	start.connect("pressed", _play_video)
	loop.connect("pressed", _loop_video)
	stop.connect("pressed", _stop_video)

func _on_load_image_pressed() -> void:
	# $FileDialog.add_filter("*.webm ; WebM Video Files")
	$FileDialog.add_filter("*.ogv ; OGV Video Files")
	$FileDialog.popup()

func _on_file_dialog_file_selected(path: String) -> void:
	videoPlayer.stream = load(path) #  Load video
	videoPlayer.expand=true # Fit into viewport
	
	# Load video frame but don't play until play button pressed
	videoPlayer.play()
	videoPlayer.paused=true
	# $LoadVideo.hide() # have commented this so that button still shows when 
						# video is loaded so you can load a different one if 
						# you want

func _loop_video() -> void:
	# Loop video button
	var is_looped = videoPlayer.loop
	
	# Invert booleen
	videoPlayer.loop=!is_looped
	
func _play_video() -> void:
	# Play/Pause button
	var paused=videoPlayer.paused
	## Invert state
	#videoPlayer.paused=!paused # commented out to add "pause" functionality
	if paused:
		videoPlayer.paused = false
		start.text = "Pause"  # Change button text to "Pause" when playing
	else:
		videoPlayer.paused = true
		start.text = "Play"   # Change button text back to "Play" when paused

func _stop_video() -> void:
	videoPlayer.stop()
	# Load video frame but don't play until play button pressed
	videoPlayer.play()
	videoPlayer.paused=true
	start.text = "Play"  # Reset button text to "Play" when stopped

	

func _show_load_button() -> void:
	$LoadVideo.show()

func _input(event):
	# Quit if pressing q
	if event.is_action_pressed('quit'):
		videoPlayer.stop()	
		videoPlayer.finished.emit()
		
	if event.is_action_pressed("play-stop"):
		_play_video()
		
	
