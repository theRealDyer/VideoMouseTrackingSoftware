extends Control


func _on_load_image_pressed() -> void:
	$FileDialog.add_filter("*.png ; PNG files")
	$FileDialog.add_filter("*.jpg ; JPG files")
	$FileDialog.add_filter("*.jpeg ; JPEG files")
	$FileDialog.popup()


func _on_file_dialog_file_selected(path: String) -> void:
	
	var image = Image.new()
	image.load(path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	
	$ColorRect/TextureRect.texture = image_texture
