extends Piece

class_name PlayablePiece

signal selected(piece)


func _on_TouchScreenButton_pressed():
	get_tree().get_root().set_input_as_handled()
	emit_signal("selected", self)
