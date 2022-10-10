extends Node2D

var file_name = ""
var board = null

func init(_file_name, _board):
	self.file_name = _file_name
	self.board = _board

	return self

func on_piece_landed(piece):
	if not piece is Enemy:
		self.board.initialize_board(self.file_name)
