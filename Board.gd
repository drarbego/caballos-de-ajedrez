extends Node2D

const Knight = preload("res://Knight.tscn")
const Tile = preload("res://Tile.tscn")

var board_tiles = Vector2(8, 8)

var black_knight = Knight.instance().init(Color.darkgray)
var white_knight = Knight.instance().init(Color.white)

var current_piece = black_knight


func _ready():
	for i in board_tiles.y:
		for j in board_tiles.x:
			var tile = Tile.instance().init(j, i)
			tile.connect("pressed", self, "on_tile_pressed")
			$Tiles.add_child(tile)

	$Pieces.add_child(self.black_knight)
	var tile_black = self.get_tile(Vector2(4, 5))
	tile_black.set_piece(self.black_knight)
	self.black_knight.set_active(true)

	$Pieces.add_child(self.white_knight)
	var tile_white = self.get_tile(Vector2(4, 4))
	tile_white.set_piece(self.white_knight)

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
