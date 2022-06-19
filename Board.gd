extends Node2D

const Knight = preload("res://Knight.tscn")
const Traveler = preload("res://Traveler.tscn")
const Tile = preload("res://Tile.tscn")
const Switch = preload("res://Switch.tscn")
const Hunter = preload("res://Hunter.tscn")

var board_tiles = Vector2(8, 8)

var current_piece = null

var is_player_turn = true


func _ready():
	for i in board_tiles.y:
		for j in board_tiles.x:
			var tile = Tile.instance().init(self, j, i)
			$Tiles.add_child(tile)

	self.initialize_board()

func get_tile(pos: Vector2):
	var tile_name = str(pos.x) + "_" + str(pos.y)

	return get_node("Tiles/" + tile_name)

func next_state(selected_tile):
	if self.current_piece and not selected_tile.current_piece and self.current_piece.can_move(selected_tile.board_pos):
		selected_tile.set_piece(self.current_piece)
		self.current_piece.tile.select_piece()
		self.move_enemies()
		self.update_enemies_direction()
		return

	if selected_tile.current_piece and selected_tile.current_piece is PlayablePiece:
		selected_tile.select_piece()

func _on_MoveTimer_timeout():
	self.move_enemies()
	self.update_enemies_direction()
	self.start_player_turn()

func start_player_turn():
	self.is_player_turn = true
	self.current_piece = null
	self.set_pieces_active(true)
	self.set_tiles_active(false)

func update_enemies_direction():
	var traveler = $Pieces.get_child(0) # fix this
	for enemy in $Enemies.get_children():
		# follow traveler
		var dir = (traveler.tile.board_pos - enemy.tile.board_pos).normalized().round()
		if abs(dir.x) == 1 and abs(dir.y) == 1:
			dir.y = 0
		enemy.set_dir(dir)


func move_enemies():
	self.is_player_turn = false
	self.set_tiles_active(true)
	for enemy in $Enemies.get_children():
		var next_tile = self.get_tile(enemy.tile.board_pos + enemy.dir)

		if not next_tile:
			continue
			
		if not next_tile.is_active:
			continue

		if not enemy.can_move(next_tile.board_pos):
			continue

		next_tile.set_piece(enemy)
	self.start_player_turn()

func initialize_board():
	# read file
	var file = File.new()
	file.open("res://test_map.txt", File.READ)
	var y = 0
	while file.get_position() < file.get_len():
		var x = 0
		for c in file.get_line():
			match c:
				"K":
					self.initialize_piece(Vector2(x, y), Knight, true)
				"T":
					self.initialize_piece(Vector2(x, y), Traveler, false)
				"E":
					self.initialize_enemy(Vector2(x, y), Hunter)
			x += 1
		y += 1

	self.update_enemies_direction()
	self.start_player_turn()

func initialize_piece(pos, piece_class, consumes_tiles): # fix consumes_tiles
	var tile = self.get_tile(pos) 
	var piece = piece_class.instance().init(self, tile, consumes_tiles)
	$Pieces.add_child(piece)
	tile.set_piece(piece)
	tile.current_piece = piece # fix this hack

func initialize_enemy(pos, piece_class):
	var tile = self.get_tile(pos) 
	var piece = piece_class.instance().init(self, tile, false)
	$Enemies.add_child(piece)
	tile.set_piece(piece)
	tile.current_piece = piece # fix this hack

func set_tiles_active(active):
	for tile in $Tiles.get_children():
		tile.is_active = active

func set_pieces_active(active):
	for piece in $Pieces.get_children():
		piece.set_active(active)

func game_over():
	self.set_tiles_active(false)
