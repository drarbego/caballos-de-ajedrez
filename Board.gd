extends Node2D

const Knight = preload("res://Knight.tscn")
const Tile = preload("res://Tile.tscn")

var board_tiles = Vector2(8, 8)

var piece = Knight.instance()


func _ready():
	for i in board_tiles.y:
		for j in board_tiles.x:
			var tile = Tile.instance().init(j, i)
			tile.connect("pressed", self, "on_tile_pressed")
			$Tiles.add_child(tile)

	$Pieces.add_child(self.piece)
	var tile = self.get_tile(Vector2(4, 4))
	tile.set_piece(self.piece)

func get_tile(pos: Vector2):
	var tile_name = str(pos.x) + "_" + str(pos.y)

	return get_node("Tiles/" + tile_name)

func on_tile_pressed(tile):
	if self.piece.can_move(self.piece.tile.board_pos, tile.board_pos):
		print("Sí ✓")
		tile.set_piece(self.piece)
	else:
		print("No ✖")
