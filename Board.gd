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
		var dir = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT][randi() % 4]
		var next_tile = self.get_tile(enemy.tile.board_pos + dir)

		if not next_tile:
			continue
			
		if not next_tile.is_active:
			continue

		if not self.current_piece.can_move(enemy.tile.board_pos, next_tile.board_pos):
			return

		next_tile.set_piece(enemy)

func initialize_board():
	var tile_knight = self.get_tile(Vector2(0, 4))
	self.knight = Knight.instance().init(tile_knight, Color.darkgray)
	$Pieces.add_child(self.knight)
	self.knight.set_tile(tile_knight)
	tile_knight.set_piece(self.knight)


	var tile_traveler = self.get_tile(Vector2(0, 3))
	self.traveler = Traveler.instance().init(tile_traveler, Color.white)
	$Pieces.add_child(self.traveler)
	self.traveler.set_tile(tile_traveler)
	tile_traveler.set_piece(self.traveler)

	self.current_piece = self.knight
	self.knight.set_active(true)

	var tile = self.get_tile(Vector2(3, 3))
	var switch = Switch.instance()
	tile.set_content(switch)

	var tile_hunter = self.get_tile(Vector2(4, 3))
	self.hunter = Hunter.instance().init(tile_hunter, Color.white)
	$Enemies.add_child(self.hunter)
	self.hunter.set_tile(tile_hunter)
	tile_hunter.set_piece(self.hunter)
