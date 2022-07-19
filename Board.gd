extends Node2D

const Knight = preload("res://Knight.tscn")
const Traveler = preload("res://Traveler.tscn")
const Tile = preload("res://Tile.tscn")
const Switch = preload("res://Switch.tscn")
const Hunter = preload("res://Hunter.tscn")

var board_tiles := Vector2(8, 8)

var current_piece = null

var is_player_turn := true
var is_selecting_tiles := false
const MAX_TRAVELER_MOVES := 2
var traveler_moves_left := MAX_TRAVELER_MOVES
var tiles_stack = []


func _ready():
	for i in board_tiles.y:
		for j in board_tiles.x:
			var tile = Tile.instance().init(self, j, i)
			$Tiles.add_child(tile)

	self.initialize_board()

func get_tile(pos: Vector2):
	var tile_name = str(pos.x) + "_" + str(pos.y)

	return get_node("Tiles/" + tile_name)

func on_tile_pressed(selected_tile):
	if selected_tile.current_piece is PlayablePiece:
		self.set_tiles_active(false)
		self.set_pieces_selectable(false)
		selected_tile.select_piece()
		if selected_tile.current_piece.TYPE == "Traveler":
			self.selecting_tiles(selected_tile.current_piece)
		else:
			self.cancel_selecting_tiles()
		return

	if not self.current_piece:
		return

	if selected_tile.is_active:
		self.next_board_state(selected_tile)
		return

func selecting_tiles(traveler):
	self.set_tiles_active(false)
	self.is_selecting_tiles = true
	self.traveler_moves_left = self.MAX_TRAVELER_MOVES
	self.tiles_stack = [traveler.tile]

func cancel_selecting_tiles():
	self.is_selecting_tiles = false

func on_tile_mouse_entered(tile):
	if not self.is_selecting_tiles:
		return

	if self.current_piece.tile == tile:
		return

	if tile == self.tiles_stack.back():
		self.tiles_stack.pop_back()
		tile.set_active(false)
		self.traveler_moves_left = clamp(self.traveler_moves_left + 1, 0, self.MAX_TRAVELER_MOVES)
		return

	if self.traveler_moves_left == 0:
		return

	if not self.tiles_stack or tile.is_adjacent_to(self.tiles_stack.back()):
		self.tiles_stack.append(tile)
		tile.set_active(true)
		self.traveler_moves_left = clamp(self.traveler_moves_left - 1, 0, self.MAX_TRAVELER_MOVES)
		return

func next_board_state(selected_tile):
	self.reset_graphic_state()

	selected_tile.set_piece(self.current_piece)
	$MoveTimer.set_wait_time(self.current_piece.move_time)
	$MoveTimer.start()
	self.set_tiles_active(false)
	print("next board state")

func reset_graphic_state():
	self.set_pieces_active(false)
	self.set_pieces_selectable(true)

func _on_MoveTimer_timeout():
	self.move_enemies()
	self.set_tiles_active(false)
	self.update_enemies_direction()

func update_enemies_direction():
	for enemy in $Enemies.get_children():
		# follow traveler
		var traveler = enemy.target
		var dir = (traveler.tile.board_pos - enemy.tile.board_pos).normalized().round()
		if abs(dir.x) == 1 and abs(dir.y) == 1:
			dir.y = 0
		enemy.set_dir(dir)


func move_enemies():
	self.is_player_turn = false
	for enemy in $Enemies.get_children():
		if enemy.is_queued_for_deletion():
			continue

		var next_tile = self.get_tile(enemy.tile.board_pos + enemy.dir)

		if not next_tile:
			continue
			
		if not enemy.can_move(next_tile.board_pos):
			continue

		if next_tile.current_piece and next_tile.current_piece is Enemy:
			continue

		if next_tile.current_piece and next_tile.current_piece is PlayablePiece:
			next_tile.current_piece.on_clash(enemy)
			 
		next_tile.set_piece(enemy)


func initialize_board():
	# OWN PIECE SYMBOLS
	# T Venado (is a Traveler that moves like a Chess King, but moves 3 tiles at a time)
	# A Ardilla (moves like a Chess Knight)

	# ENEMY SYMBOLS
	# ! Slow Hunter
	# @ Fast Hunter
	# $ Archer

	# read test map

	var file = File.new()
	file.open("res://test_map.txt", File.READ)
	var traveler = null

	var y = 0
	while file.get_position() < file.get_len():
		var x = 0
		for c in file.get_line():
			match c:
				"T":
					traveler = self.initialize_piece(Vector2(x, y), Traveler, false)
				"A":
					self.initialize_piece(Vector2(x, y), Knight, true)
				"!":
					self.initialize_enemy(Vector2(x, y), Hunter)
			x += 1
		y += 1

	self.set_enemies_target(traveler)
	self.update_enemies_direction()
	self.set_tiles_active(false)
	self.reset_graphic_state()

func initialize_piece(pos, piece_class, consumes_tiles): # fix consumes_tiles
	var tile = self.get_tile(pos) 
	var piece = piece_class.instance().init(self, tile, consumes_tiles)
	$Pieces.add_child(piece)
	tile.set_piece(piece)
	tile.current_piece = piece # fix this hack

	return piece

func initialize_enemy(pos, piece_class):
	var tile = self.get_tile(pos) 
	var piece = piece_class.instance().init(self, tile, false)
	$Enemies.add_child(piece)
	tile.set_piece(piece)
	tile.current_piece = piece # fix this hack

	return piece

# TILES
func set_tiles_active(active):
	for tile in $Tiles.get_children():
		tile.is_active = active

# OWN PIECES
func set_pieces_active(active):
	for piece in $Pieces.get_children():
		piece.set_active(active)

func set_pieces_selectable(selectable):
	for piece in $Pieces.get_children():
		piece.set_selectable(selectable)

func set_enemies_target(target):
	for piece in $Enemies.get_children():
		piece.set_target(target)

func game_over():
	self.set_tiles_active(false)
