require_relative 'lib/game'
require_relative 'lib/board'
require_relative 'lib/player'
require_relative 'lib/ui'
require_relative 'lib/chess_piece'

game = Game.new(:test)

instruction = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - - 0 1"
game.board.convert_fen_to_board(instruction)


game.game_sequence_start