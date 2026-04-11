require_relative 'lib/game'
require_relative 'lib/board'
require_relative 'lib/player'
require_relative 'lib/ui'
require_relative 'lib/chess_piece'

game = Game.new
instruction = "8/3k4/8/pppppppp/PPPPPPP1/7P/3K4/8 w - - 99 1"
# game.board.convert_fen_to_board(instruction)
game.game_sequence_start
