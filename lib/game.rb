require_relative 'board'
require_relative 'player'
require_relative 'ui'
require_relative 'chess_piece'

class Game
  attr_accessor :ui, :board, :p1, :p2, :white_king, :black_king
  def initialize
    @board = Board.new
    # Load save game logic here
    @board.prepare_for_new_game
    @white_king = [7, 4]
    @black_king = [0, 4]
    @ui = UI.new
    player_nicknames = @ui.get_new_players_name
    @p1 = Player.new(player_nicknames[0], :white)
    @p2 = Player.new(player_nicknames[1], :black)
  end

  def game_sequence_start
    
    done = false
    until done
      # Here should be check-mate and mate condition verification
      
      # Here should be CHECK! alert if king under attack after previous player turn.

      pieces = get_remaining_pieces(@board.state, @board.turn)
      
      # Get player valid pick and destination.
      destination, pick, moves = nil, nil, nil
      until destination
        transition = ensure_transition(pieces)
        pick, moves = transition[0], transition[1]
        if pick == :exit
          # Here check for "Exit & Save the game" needed
          system("exit") # Temporary
        end
        
        @ui.clear
        @ui.render_board(@board.state, moves)
        destination = @ui.get_player_move(moves, @board.state)
      end

      piece_in_transit = @board.state[pick[0]][pick[1]].dup
      @board.state[pick[0]][pick[1]] = nil
      if king_not_in_danger?(@board.turn)
        @board.state[destination[0]][destination[1]] = piece_in_transit.dup
        transited_piece = @board.state[destination[0]][destination[1]]
        transited_piece.position = [destination[0], destination[1]]
        transited_piece.castling = false if transited_piece.castling
        case transited_piece.type
        when :king 
          transited_piece.colour == :white ? @white_king = [destination[0], destination[1]] : @black_king = [destination[0], destination[1]]
        when :pawn 
          transited_piece.en_passant = true if [-2, 2].include?(pick[0] - destination[0])
          if (transited_piece.colour == :white && transited_piece.position[0] == 0) 
            || (transited_piece.colour == :black && transited_piece.position[0] == 7)
            transform_pawn(transited_piece.position, @board.state)  
          end
        end
        check_condition = transited_piece.get_moves(transited_piece.position, @board.state)
        if transited_piece.colour == :white
          @board.state[@black_king[0]][@black_king[1]].under_attack = true if check_condition.include?(@black_king)
        elsif transited_piece.colour == :black
          @board.state[@white_king[0]][@white_king[1]].under_attack = true if check_condition.include?(@white_king)
        end
        @board.turn == :white ? @board.turn = :black : @board.turn = :white
        # This is infinite cycle now. Exit condition needed (Check/Mate, Mate, Save)
      else
        @board.state[pick[0]][pick[1]] = piece_in_transit
        @ui.clear
        @ui.alert_king_is_vulnerable
      end
    end

  end

  def get_remaining_pieces(board, turn)
    pieces = []
    board.each do |row|
      row.each do |square|
        next if !square
        if square.colour == turn
          pieces << square.position
          square.en_passant = false if square.en_passant
        end
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
      @board.turn == :white ? pick = @ui.get_pick(@p1, pieces, @board.state) : pick = @ui.get_pick(@p2, pieces, @board.state)
      if pick == :exit
        checked = true
        return [pick, nil]
      end
      moves = @board.state[pick[0]][pick[1]].get_moves(pick, @board.state)
      if moves.empty?
        @ui.clear
        @ui.alert_piece_block(pick, @board.state)
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
    x, y = position[0], position[1]
    player_choice = @ui.choose_piece
    @board[x][y] = Chess_piece.new(player_choice, board.turn, [x, y])
  end

end