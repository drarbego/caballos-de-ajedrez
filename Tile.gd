extends Node2D


var tile_size = 64
var board_pos = Vector2.ZERO
var board = null
var current_piece = null
var is_active = true

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

func _on_pressed():
	if self.current_piece is PlayablePiece:
		self.board.set_tiles_active(false)
		self.board.set_pieces_selectable(false)
		self.select_piece()
		return

	if not self.board.current_piece:
		return

	if self.is_active:
		self.board.next_board_state(self)
		return

func select_piece():
	# makes the available tiles of the current piece active
	if not self.current_piece:
		return

	self.current_piece.set_active(true)

	for move in self.current_piece.moves:
		var tile = self.board.get_tile(self.board_pos + move)
		if tile:
			if self.current_piece.TYPE == "Traveler":
				if not tile.current_piece and not self.board.crosses_enemy(self, tile):
					tile.set_active(true)
			else:
				tile.set_active(true)
				if tile.current_piece and tile.current_piece is Enemy and self.current_piece.attacks:
					tile.set_active(true) # set attackable

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

func is_adjacent_to(tile):
	return (
		tile.board_pos + Vector2.UP == self.board_pos or
		tile.board_pos + Vector2.DOWN == self.board_pos or
		tile.board_pos + Vector2.LEFT == self.board_pos or
		tile.board_pos + Vector2.RIGHT == self.board_pos
	)

func _process(delta):
	$TextureButton.modulate = Color.white if self.is_active else Color.darkgray
	$Label.set_text(str(self.current_piece) if self.current_piece else "_")

func set_content(node_content):
	for child in $Content.get_children():
		child.queue_free()

	$Content.add_child(node_content)

func has_content():
	return $Content.get_child_count() > 0

func reset():
	self.current_piece = null
	self.is_active = true
	for child in $Content.get_children():
		child.queue_free()
