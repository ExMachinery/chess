require_relative 'lib/game'
require_relative 'lib/board'
require_relative 'lib/player'
require_relative 'lib/ui'
require_relative 'lib/chess_piece'

game = Game.new(:test)
instruction = "KR4rk/P7/8/N7/8/8/4b3/8 b - - 0 1"
game.board.convert_fen_to_board(instruction)
game.game_sequence_start