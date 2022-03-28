extends Node2D


var tile_size = 64
var board_pos = Vector2.ZERO
var current_piece = null
var is_active = true

signal pressed

func init(x, y):
	self.board_pos = Vector2(x, y)
	self.name = str(x) + "_" + str(y)

	return self

func set_piece(piece):
	piece.move_to_tile(self)
	piece.set_tile(self)
	self.current_piece = piece

func _on_pressed():
	emit_signal("pressed", self)

func _ready():
	self.position = self.board_pos * tile_size

func consume_tile():
	self.is_active = false

func _process(delta):
	$TextureButton.modulate = Color.white if self.is_active else Color.darkgray
