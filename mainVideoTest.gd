extends Control

# Get references to button nodes & Video node
@onready var videoPlayer = $VideoBounds/VideoStreamPlayer
@onready var start = $Start
@onready var loop = $Loop
@onready var zoom = $Zoom

func _ready():
	# Linking signals 
	videoPlayer.connect("finished", _show_load_button)
	start.connect("pressed", _play_video)
	loop.connect("pressed", _loop_video)
	zoom.connect("value_changed", _zoomed)
	
	
	

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
	zoom.show()

func _zoomed(scale_factor:float) -> void:
	# increase the scale of the video
	videoPlayer.scale=Vector2(scale_factor, scale_factor)

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
	
	# Hide video tools when no video
	start.hide()
	loop.hide()
	zoom.hide()
	

func _input(event) -> void:
	# Quit if pressing q
	if event.is_action_pressed('quit'):
		videoPlayer.stop()	
		videoPlayer.finished.emit()
		
	if event.is_action_pressed("play-stop"):
		_play_video()

		
	
