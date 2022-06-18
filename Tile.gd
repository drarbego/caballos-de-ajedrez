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
	if self.current_piece and piece:
		print(self.current_piece)
		if self.current_piece.has_method("on_clash"):
			self.current_piece.on_clash(piece)

	self.current_piece = piece

	if not piece:
		return

	piece.tile.set_piece(null)
	piece.move_to_tile(self)
	piece.set_tile(self)

	for child in $Content.get_children():
		child.on_piece_landed(piece)

func _on_pressed():
	emit_signal("pressed", self)

func _ready():
	self.position = self.board_pos * tile_size

func consume_tile():
	self.is_active = false

func _process(delta):
	$TextureButton.modulate = Color.white if self.is_active else Color.darkgray
	$Label.set_text(str(self.current_piece) if self.current_piece else "_")

func set_content(node_content):
	for child in $Content.get_children():
		child.queue_free()

	$Content.add_child(node_content)

func toggle():
	pass
