extends Control

@onready var videoPlayer = $VideoStreamPlayer
@onready var boundSize = self.size # Bounding box position
@onready var localRect = Rect2(Vector2.ZERO, self.get_rect().size)

@onready var zoom = $"../Zoom"


# Variables for moving zoomed video
var dragging=false
var dragOffset=Vector2()

func _ready():
	zoom.connect("value_changed", _zoomed)



func _zoomed(scale_factor:float) -> void:
	var newPos=Vector2()
	# increase the scale of the video
	videoPlayer.scale=Vector2(scale_factor, scale_factor)
	
	### Keep video in frame
	#videoPlayer.global_position.x = clamp(videoPlayer.global_position.x, boundPos.x-abs(videoBounds.size.x \
				#- videoPlayer.size.x*videoPlayer.scale.x), boundPos.x)
	#videoPlayer.global_position.y = clamp(videoPlayer.global_position.y, boundPos.y-abs(videoBounds.size.y \
				#- videoPlayer.size.y*videoPlayer.scale.y), boundPos.y)
	#videoPlayer.global_position=newPos

func _input(event):
	event = make_input_local(event) # convert to local coords
	if event is InputEventMouseButton:
		if self.localRect.has_point(event.position) and \
				event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Start dragging (Only if clicked on video space)
			dragging=true
			dragOffset=videoPlayer.position-event.position
			print()
			print(dragOffset)
		else:
			dragging=false # Stop dragging
			
	if event is InputEventMouseMotion:
		
		if dragging:
			# Move video to new position if holding mouse button
			var newPos = event.position+dragOffset
			#print(videoPlayer.position, newPos)
			var minPos = self.get_rect().size - videoPlayer.get_rect().size
			var maxPos = -minPos
			# Bind video to viewing box		
			#print(minPos)

			newPos = newPos.clamp(minPos/2, maxPos/2)
				

			videoPlayer.position=newPos
			print(videoPlayer.position)
			print(videoPlayer.get_rect().position)

			
	if event.is_action_pressed("DEBUG"):
		var minPos = self.get_rect().size - videoPlayer.get_rect().size
		print("video rect size ", videoPlayer.get_rect().size)
		print("video rect position ", videoPlayer.get_rect().position)		
		print("Min position", minPos)
		
		var test = Vector2(-500, -300)
		print(test.clamp(minPos, Vector2.ZERO))
		
		
