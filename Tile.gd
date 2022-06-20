extends Node2D


var tile_size = 64
var board_pos = Vector2.ZERO
var board = null
var current_piece = null
var is_active = true

signal pressed(tile)

func init(_board, x, y):
	self.board = _board
	self.board_pos = Vector2(x, y)
	self.name = str(x) + "_" + str(y)

	return self

func set_piece(piece):
	if self.current_piece and piece:
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
	self.board.next_state(self)

func select_piece():
	if not self.current_piece:
		return

	self.board.set_tiles_active(false)
	self.board.set_pieces_active(false)
	self.current_piece.set_active(true)

	for move in self.current_piece.moves:
		var tile = self.board.get_tile(self.board_pos + move)
		if tile:
			tile.set_active(true)

	self.board.current_piece = self.current_piece

func move_piece_to_tile():
	if self.current_piece:
		return
		# handle piece already_here

	var piece = self.board.current_piece
	if piece.can_move(piece.tile.board_pos, self.board_pos):
		self.set_piece(piece)

func set_active(active):
	self.is_active = active

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
