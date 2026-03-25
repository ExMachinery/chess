require_relative 'board'
require_relative 'player'
require_relative 'ui'
require_relative 'chess_piece'

class Game
  attr_accessor :ui, :board, :p1, :p2, :white_king, :black_king
  def initialize
    @board = Board.new
    # Load save game logic here
    board.prepare_for_new_game
    @white_king = [7, 4]
    @black_king = [0, 4]
    @ui = UI.new
    player_nicknames = ui.get_new_players_name
    @p1 = Player.new(player_nicknames[0], :white)
    @p2 = Player.new(player_nicknames[1], :black)
  end

  def game_sequence_start
    
    done = false
    until done
      pieces = get_remaining_pieces(@board.state, @board.turn)

    end

  end

  def get_remaining_pieces(board, turn)
    pieces = []
    board.each do |row|
      row.each do |square|
        next if !square
        pieces << square.position if square.colour == turn
        square.en_passant = false if square.type == :pawn && square.en_passant
      end
    end
    pieces
  end

end