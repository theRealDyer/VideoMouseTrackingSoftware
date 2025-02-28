extends Control

# Get references to button nodes & Video node
@onready var videoPlayer = $VideoBounds/VideoStreamPlayer
@onready var videoBounds = $VideoBounds
@onready var start = $Start
@onready var stop = $Stop
@onready var loop = $Loop
@onready var zoom = $Zoom
@onready var boundPos = videoBounds.global_position
@onready var exportJsonButton = $ExportJSON
@onready var resolutionDropDown = $ResolutionDropDown
@onready var frameRateSelect = $FrameRateSelect
@onready var videoProgressBar = $VideoProgressBar
@onready var movementControl = $VideoBounds

# Logging-related variables
var frames_data: Array = []
var is_logging: bool = false
var time_accumulator: float = 0.0

# If you want to let the user choose framerate, store it here; otherwise set a default:
var target_fps: float = 30.0
var target_frame_time: float = 1.0 / target_fps

# Variables for moving zoomed video
var dragging=false
var dragOffset=Vector2()

func _ready():
	
	videoProgressBar.min_value = 0
	videoProgressBar.max_value = 1
	
	# Linking signals 
	videoPlayer.connect("finished", _show_load_button)
	start.connect("pressed", _play_video)
	loop.connect("pressed", _loop_video)
	stop.connect("pressed", _stop_video)
	exportJsonButton.connect("pressed", _export_json)
	
	# resolution options
	var resolutions = [
		"320x240", "640x480", "720x480", "720x576",
		"800x600", "960x540", "1024x768", "1136x640",
		"1280x720", "1366x768", "1600x900", "1920x1080",
		"2048x1080", "2560x1080", "2560x1440", "3440x1440",
		"3840x2160", "4096x2160", "5120x2880", "7680x4320"
		]
	for resolution in resolutions:
		resolutionDropDown.add_item(resolution)

# function to export json file upon button press
func _export_json() -> void:
	# Example of building the final data:
	var json_data = {
		"resolution": resolutionDropDown.get_item_text(resolutionDropDown.selected),
		"fps": target_fps,
		"frames": frames_data
	}

	var json = JSON.new()
	var path = "user://exported_data.json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(json.stringify(json_data, "  ")) # With indentation for readability

	file.close()
	print("success; json exported to: ", path)


	
func _on_load_image_pressed() -> void:
	# $FileDialog.add_filter("*.webm ; WebM Video Files")
	$FileDialog.add_filter("*.ogv ; OGV Video Files")
	$FileDialog.popup()

func _process(delta: float) -> void:
	var playback = videoPlayer.get_stream_length()

	if playback:
		var current_position = playback.get_position()
		var total_length = playback.get_length()
		print("DEBUG => position:", current_position, " length:", total_length)
		if total_length > 0:
			videoProgressBar.value = current_position / total_length
		else:
			videoProgressBar.value = 0
			
	if is_logging:
		# Accumulate time to respect the user-chosen FPS 
		time_accumulator += delta
		while time_accumulator >= target_frame_time:
			time_accumulator -= target_frame_time
			_log_frame_data()


func _log_frame_data() -> void:
	# We want: 
	#  - The center of view (as determined by the controlMovement logic).
	#  - The zoom scale (slider or VideoStreamPlayer scale).
	
	# call function from controlMovement that returns the center of the view.
	var view_center = movementControl.get_view_center()
	
	# get the current zoom. 
	var current_zoom_percent = movementControl.get_zoom_percentage()

	var frame_dict = {
		"center_x": view_center.x,
		"center_y": view_center.y,
		"zoom": current_zoom_percent
	}
	frames_data.append(frame_dict)


func _on_file_dialog_file_selected(path: String) -> void:
	videoPlayer.stream = load(path) #  Load video
	videoPlayer.expand=true # Fit into viewport
	
	videoPlayer.global_position = videoBounds.global_position
	videoPlayer.size = videoBounds.size
	
	# Load video frame but don't play until play button pressed
	videoPlayer.play()
	videoPlayer.paused=true
	# $LoadVideo.hide() # have commented this so that button still shows when 
						# video is loaded so you can load a different one if 
						# you want
	start.show()
	loop.show()
	zoom.show()

func _loop_video() -> void:
	# Loop video button
	var is_looped = videoPlayer.loop
	# Invert state
	videoPlayer.loop=!is_looped
	
	loop.release_focus() # Ensures spacepress doesn't trigger button
	
func _play_video() -> void:
	# Play/Pause button
	var paused=videoPlayer.paused
	## Invert state
	#videoPlayer.paused=!paused # commented out to add "pause" functionality
	if paused:
		# Grab spinbox value
		target_fps = frameRateSelect.value
		target_frame_time = 1.0 / target_fps
		
		videoPlayer.paused = false
		start.text = "Pause"  # Change button text to "Pause" when playing
		is_logging = true # start logging
	else:
		videoPlayer.paused = true
		start.text = "Play"   # Change button text back to "Play" when paused
		is_logging = false  # Pause logging
		
	
	
	
func _stop_video() -> void:
	videoPlayer.stop()
	# Load video frame but don't play until play button pressed
	videoPlayer.play()
	videoPlayer.paused=true
	start.text = "Play"  # Reset button text to "Play" when stopped
	
	is_logging = false # pause logging
	
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

