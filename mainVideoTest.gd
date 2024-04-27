extends Control

# Get references to button nodes & Video node
@onready var videoPlayer = $VideoStreamPlayer
@onready var start = $Start
@onready var loop = $Loop
@onready var iZoom = $InitialZoom

func _ready():
	# Linking signals 
	videoPlayer.connect("finished", _show_load_button)
	start.connect("pressed", _play_video)
	loop.connect("pressed", _loop_video)
	

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
	$LoadVideo.hide()
	start.show()
	loop.show()

func _loop_video() -> void:
	# Loop video button
	var is_looped = videoPlayer.loop
	
	# Invert booleen
	videoPlayer.loop=!is_looped
	
	loop.release_focus() # Ensures spacepress doesn't trigger button
	
func _play_video() -> void:
	# Play/Pause button
	var paused=videoPlayer.paused
	# Invert state
	videoPlayer.paused=!paused
	
	start.release_focus()# Ensures spacepress doesn't trigger button
	

func _show_load_button() -> void:
	$LoadVideo.show()

func _input(event) -> void:
	# Quit if pressing q
	if event.is_action_pressed('quit'):
		videoPlayer.stop()	
		videoPlayer.finished.emit()
		
	if event.is_action_pressed("play-stop"):
		_play_video()

		
	
