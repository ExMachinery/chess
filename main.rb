require_relative 'lib/game'
require_relative 'lib/board'
require_relative 'lib/player'
require_relative 'lib/ui'
require_relative 'lib/chess_piece'

game = Game.new
# Uncomment next two lines. Add (:test) to Game.new above to launch programm in testing mode. Use FEN as a 'instruction' string
# to load specific board state.
# instruction = ""
# game.board.convert_fen_to_board(instruction)
game.game_sequence_start
