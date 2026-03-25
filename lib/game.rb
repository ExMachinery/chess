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
      moves = ensure_pick(pieces)
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

  def ensure_pick(pieces)
    moves = nil
    checked = false
    until checked
      @ui.render_board(@board.state)
      @ui.print_piecelist(pieces, @board.state)
      @board.turn == :white ? pick = @ui.get_pick(@p1, pieces, @board.state) : pick = ui.get_pick(@p2, pieces, @board.state)
      if !pick
        checked = true
        # Here is save game method and exit condition
      end
      moves = @board.state[pick[0]][pick[1]].get_moves(pick, @board.state)
      if moves = []
        ui.clear
        ui.alert_piece_block(pick, @board.state)
      else
        checked = true
      end
    end
    moves
  end

end