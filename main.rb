require_relative 'lib/game'
require_relative 'lib/board'
require_relative 'lib/player'
require_relative 'lib/ui'
require_relative 'lib/chess_piece'

game = Game.new(:test)
instruction = "k7/8/8/8/5q2/8/7B/7K w - - 0 1"
game.board.convert_fen_to_board(instruction)
game.game_sequence_start
