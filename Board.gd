extends Node2D

const Knight = preload("res://Knight.tscn")
const Traveler = preload("res://Traveler.tscn")
const Tile = preload("res://Tile.tscn")
const Switch = preload("res://Switch.tscn")
const Hunter = preload("res://Hunter.tscn")
const Teleporter = preload("res://Teleporter.tscn")

var board_tiles := Vector2(8, 8)

var current_piece = null

var is_player_turn := true
var is_selecting_tiles := false
const MAX_TRAVELER_MOVES := 2
var traveler_moves_left := MAX_TRAVELER_MOVES
var tiles_stack = []


func _ready():
	self.initialize_tiles()
	self.initialize_board("map_1.txt")

func get_tile(pos: Vector2):
	var tile_name = str(pos.x) + "_" + str(pos.y)

	return get_node("Tiles/" + tile_name)

func next_board_state(selected_tile):
	self.reset_graphic_state()

	selected_tile.set_piece(self.current_piece)
	$MoveTimer.set_wait_time(self.current_piece.move_time)
	$MoveTimer.start()
	self.set_tiles_active(false)

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

func crosses_enemy(from_tile, to_tile):
	var current_tile = from_tile
	while (current_tile and current_tile != to_tile):
		if current_tile != from_tile and current_tile.current_piece:
			return true

		var dir = (to_tile.board_pos - current_tile.board_pos).normalized().round()
		current_tile = self.get_tile(current_tile.board_pos + dir)

	return false

func initialize_board(file_name):
	# OWN PIECE SYMBOLS
	# T Venado (is a Traveler that moves like a Chess King, but moves 3 tiles at a time)
	# A Ardilla (moves like a Chess Knight)

	# ENEMY SYMBOLS
	# ! Slow Hunter
	# @ Fast Hunter
	# $ Archer

	# reset state 
	$MoveTimer.stop()
	for piece in $Pieces.get_children():
		piece.queue_free()
	for enemy in $Enemies.get_children():
		enemy.queue_free()
	for tile in $Tiles.get_children():
		tile.reset()


	# read test map
	var file = File.new()
	file.open("res://" + file_name, File.READ)

	var id_to_teleporter = self.read_teleporters_section(file)
	var traveler = self.read_board_section(file, id_to_teleporter)

	self.set_enemies_target(traveler)
	self.update_enemies_direction()
	self.set_tiles_active(false)
	self.reset_graphic_state()

func read_teleporters_section(file):
	var id_to_teleporter = {}
	while file.get_position() < file.get_len():
		var line = file.get_line()
		if line[0] == ">":
			return id_to_teleporter
		var splitted_line = line.split(" ")
		var id = splitted_line[0]
		var file_name = splitted_line[1]
		id_to_teleporter[id] = Teleporter.instance().init(file_name, self)

	return id_to_teleporter

func read_board_section(file, id_to_teleporter):
	var traveler = null
	var y = 0
	while file.get_position() < file.get_len():
		var x = 0
		for c in file.get_line():
			if c >= "0" and c <= "9":
				var teleporter = id_to_teleporter[c]
				self.initialize_teleporter(Vector2(x, y), teleporter)
			match c:
				"T":
					traveler = self.initialize_piece(Vector2(x, y), Traveler, false)
				"A":
					self.initialize_piece(Vector2(x, y), Knight, true)
				"!":
					self.initialize_enemy(Vector2(x, y), Hunter)
			x += 1
		y += 1

	return traveler

func initialize_tiles():
	for i in board_tiles.y:
		for j in board_tiles.x:
			var tile = Tile.instance().init(self, j, i)
			$Tiles.add_child(tile)

func initialize_piece(pos, piece_class, consumes_tiles): # fix consumes_tiles
	var tile = self.get_tile(pos) 
	var piece = piece_class.instance().init(self, tile, consumes_tiles)
	piece.position = tile.position
	$Pieces.add_child(piece)
	tile.set_piece(piece)
	tile.current_piece = piece # fix this hack

	return piece

func initialize_enemy(pos, piece_class):
	var tile = self.get_tile(pos) 
	var piece = piece_class.instance().init(self, tile, false)
	piece.position = tile.position
	$Enemies.add_child(piece)
	tile.set_piece(piece)
	tile.current_piece = piece # fix this hack

	return piece

func initialize_teleporter(pos, teleporter):
	var tile = self.get_tile(pos)
	tile.set_content(teleporter)

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
