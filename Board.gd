extends Node2D

const Knight = preload("res://Knight.tscn")
const Tile = preload("res://Tile.tscn")
const Switch = preload("res://Switch.tscn")
const Hunter = preload("res://Hunter.tscn")

var board_tiles = Vector2(8, 8)

var black_knight = null
var white_knight = null

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

func next_piece():
	self.current_piece.set_active(false)
	self.current_piece = self.black_knight if self.current_piece == self.white_knight else self.white_knight
	self.current_piece.set_active(true)

func initialize_board():
	var tile_black = self.get_tile(Vector2(0, 4))
	self.black_knight = Knight.instance().init(tile_black, Color.darkgray)
	$Pieces.add_child(self.black_knight)
	self.black_knight.set_tile(tile_black)
	tile_black.set_piece(self.black_knight)


	var tile_white = self.get_tile(Vector2(0, 3))
	self.white_knight = Knight.instance().init(tile_white, Color.white)
	$Pieces.add_child(self.white_knight)
	self.white_knight.set_tile(tile_white)
	tile_white.set_piece(self.white_knight)

	self.current_piece = self.black_knight
	self.black_knight.set_active(true)

	var tile = self.get_tile(Vector2(3, 3))
	var switch = Switch.instance()
	tile.set_content(switch)

	tile = self.get_tile(Vector2(4, 3))
	var hunter = Hunter.instance()
	tile.set_content(hunter)
