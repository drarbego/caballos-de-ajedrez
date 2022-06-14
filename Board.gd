extends Node2D

const Knight = preload("res://Knight.tscn")
const Traveler = preload("res://Traveler.tscn")
const Tile = preload("res://Tile.tscn")
const Switch = preload("res://Switch.tscn")
const Hunter = preload("res://Hunter.tscn")

var board_tiles = Vector2(8, 8)

var current_piece_index = 0
var current_piece = null

# make a list of enemies per board/level
var hunter = null


func _ready():
	for i in board_tiles.y:
		for j in board_tiles.x:
			var tile = Tile.instance().init(j, i)
			tile.connect("pressed", self, "on_tile_pressed")
			$Tiles.add_child(tile)

	self.initialize_board()

func get_tile(pos: Vector2):
	var tile_name = str(pos.x) + "_" + str(pos.y)

	return get_node("Tiles/" + tile_name)

func on_tile_pressed(tile):
	if not tile.is_active:
		return

	if not self.current_piece.can_move(self.current_piece.tile.board_pos, tile.board_pos):
		return

	self.current_piece.tile.set_piece(null)
	tile.set_piece(self.current_piece)
	$MoveTimer.set_wait_time(self.current_piece.move_time)
	$MoveTimer.start()

func _on_MoveTimer_timeout():
	self.move_enemies()
	self.next_piece()

func next_piece():
	self.current_piece.set_active(false)
	self.current_piece_index = (self.current_piece_index + 1) % $Pieces.get_child_count()
	self.current_piece = $Pieces.get_child(self.current_piece_index)
	self.current_piece.set_active(true)

func move_enemies():
	var traveler = $Pieces.get_child(0) # fix this
	for enemy in $Enemies.get_children():
		# follow traveler
		var dir = (traveler.tile.board_pos - enemy.tile.board_pos).normalized().round()
		if abs(dir.x) == 1 and abs(dir.y) == 1:
			dir.y = 0
		var next_tile = self.get_tile(enemy.tile.board_pos + dir)

		if not next_tile:
			continue
			
		if not next_tile.is_active:
			continue

		if not enemy.can_move(enemy.tile.board_pos, next_tile.board_pos):
			continue

		next_tile.set_piece(enemy)

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
					self.initialize_piece(Vector2(x, y), Knight, true, true)
				"T":
					self.initialize_piece(Vector2(x, y), Traveler, false, true)
				"E":
					self.initialize_piece(Vector2(x, y), Hunter, false, false)
			x += 1
		y += 1

	self.current_piece = $Pieces.get_child(self.current_piece_index)
	self.current_piece.set_active(true)

func initialize_piece(pos, piece_class, consumes_tiles, is_controllable):
	var tile = self.get_tile(pos) 
	var piece = piece_class.instance().init(tile, consumes_tiles)
	var container = $Pieces if is_controllable else $Enemies
	container.add_child(piece)
	piece.set_tile(tile)
	tile.set_piece(piece)
