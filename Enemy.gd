extends Piece

class_name Enemy

var dir = Vector2.ZERO
var target = null

func _ready():
	self.attacks = true

func set_dir(new_dir: Vector2):
	self.dir = new_dir

func set_target(new_target: Piece):
	self.target = new_target

func get_class():
	return "Enemy"

func move_to_next_tile():
	var next_tile = self.board.get_tile(self.tile.board_pos + self.dir)

	if not next_tile:
		return

	if not self.can_move(next_tile.board_pos):
		return

	if next_tile.current_piece and next_tile.current_piece.get_class() == self.get_class():
		return

	if next_tile.current_piece and next_tile.current_piece is PlayablePiece:
		next_tile.current_piece.on_clash(self)
			 
	next_tile.set_piece(self)

func update_direction():
	var target_pos = self.target.tile.board_pos

	var shortest_dist = INF
	var resulting_dir = Vector2.ZERO

	for d in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var neighbor_tile = self.tile.get_neighbor_tile_at(d)
		if not neighbor_tile:
			continue
		var length_vector = target_pos - neighbor_tile.board_pos
		if length_vector.length() < shortest_dist:
			if not neighbor_tile.has_enemy() and not neighbor_tile.has_content():
				shortest_dist = length_vector.length()
				resulting_dir = d

	self.set_dir(resulting_dir)
