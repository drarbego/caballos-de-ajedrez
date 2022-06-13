extends Node2D

const Knight = preload("res://Knight.tscn")
const Traveler = preload("res://Traveler.tscn")
const Tile = preload("res://Tile.tscn")
const Switch = preload("res://Switch.tscn")
const Hunter = preload("res://Hunter.tscn")

var board_tiles = Vector2(8, 8)

var knight = null
var traveler = null

# make a list of enemies per board/level
var hunter = null

var current_piece = null

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

	tile.set_piece(self.current_piece)
	self.next_piece()
	self.move_enemies()

func next_piece():
	self.current_piece.set_active(false)
	self.current_piece = self.traveler if self.current_piece == self.knight else self.knight
	self.current_piece.set_active(true)

func move_enemies():
	for enemy in $Enemies.get_children():
		# follow traveler
		var dir = (self.traveler.tile.board_pos - enemy.tile.board_pos).normalized().round()
		if abs(dir.x) == 1 and abs(dir.y) == 1:
			dir.y = 0
		var next_tile = self.get_tile(enemy.tile.board_pos + dir)

		if not next_tile:
			continue
			
		if not next_tile.is_active:
			continue

		if not self.current_piece.can_move(enemy.tile.board_pos, next_tile.board_pos):
			return

		next_tile.set_piece(enemy)

func initialize_board():
	# read file
	var file = File.new()
	file.open("res://test_map.txt", File.READ)
	var y = 0
	while file.get_position() < file.get_len():
		var x = 0
		for c in file.get_line():
			print(c)
			match c:
				"K":
					self._initialize_knight(Vector2(x, y))
				"T":
					self._initialize_traveler(Vector2(x, y))
				"E":
					self._initialize_enemy(Vector2(x, y))
			x += 1
		y += 1

	self.current_piece = self.knight
	self.knight.set_active(true)

	var tile = self.get_tile(Vector2(3, 3))
	var switch = Switch.instance()
	tile.set_content(switch)


func _initialize_knight(pos):
	var tile_knight = self.get_tile(pos)
	self.knight = Knight.instance().init(tile_knight, Color.darkgray, true)
	$Pieces.add_child(self.knight)
	self.knight.set_tile(tile_knight)
	tile_knight.set_piece(self.knight)

func _initialize_traveler(pos):
	var tile_traveler = self.get_tile(pos)
	self.traveler = Traveler.instance().init(tile_traveler, Color.white, false)
	$Pieces.add_child(self.traveler)
	self.traveler.set_tile(tile_traveler)
	tile_traveler.set_piece(self.traveler)

func _initialize_enemy(pos):
	var tile_hunter = self.get_tile(pos)
	self.hunter = Hunter.instance().init(tile_hunter, Color.white, false)
	$Enemies.add_child(self.hunter)
	self.hunter.set_tile(tile_hunter)
	tile_hunter.set_piece(self.hunter)
