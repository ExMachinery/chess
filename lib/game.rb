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
      transition = ensure_transition(pieces)
      pick, moves = transition[0], transition[1]
      destination = ui.get_move(moves, @board.state)
      piece_in_transit = @board.state[pick[0]][pick[1]].dup
      @board.state[pick[0]][pick[1]] = nil
      if king_not_in_danger?
        @board.state[destination[0]][destination[1]] = piece_in_transit.dup
        transited_piece = @board.state[destination[0]][destination[1]].
        transited_piece.position = [destination[0], destination[1]]
        transited_piece.castling = false if transited_piece.castling
        case transited_piece.type
        when :king 
          transited_piece.colour == :white ? @white_king = [destination[0], destination[1]] : @black_king = [destination[0], destination[1]]
        when :pawn 
          transited_piece.en_passant = true if [-2, 2].include?(pick[0] - destination[0])
          if (transited_piece.colour == :white && transited_piece.positon[0] == 0) 
            || (transited_piece.colour == :black && transited_piece.positon[0] == 7)
            transform_pawn(transited_piece.position, @board.state)  
          end
        end
      else
        @board.state[pick[0]][pick[1]] = piece_in_transit
        # UI Method to alert on king in danger
      end
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

  def ensure_transition(pieces)
    pick = nil
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
    return [pick, moves]
  end

  def king_not_in_danger?(turn)
    turn == :white ? check = @white_king : check = @black_king
    result = @board.state[check[0]][check[1]].exclude_dangerous_king_moves([check], @board.state)
    result ? true : false
  end

  def transform_pawn(position, board)
    
  end

end