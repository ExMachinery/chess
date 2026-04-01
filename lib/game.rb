require_relative 'board'
require_relative 'player'
require_relative 'ui'
require_relative 'chess_piece'

class Game
  attr_accessor :ui, :board, :p1, :p2, :white_king, :black_king, :white_king_attacked_by, :black_king_attacked_by
  def initialize(instruction = nil)
    if instruction == :test
      @board = Board.new
      @ui = UI.new
      @p1 = Player.new("Big Beaver", :white)
      @p2 = Player.new("Small Beaver", :black)
    else
      @board = Board.new
      # Load save game logic here
      @board.prepare_for_new_game
      @white_king = [7, 4]
      @black_king = [0, 4]
      @white_king_attacked_by = nil
      @black_king_attacked_by = nil
      @ui = UI.new
      player_nicknames = @ui.get_new_players_name
      @p1 = Player.new(player_nicknames[0], :white)
      @p2 = Player.new(player_nicknames[1], :black)
    end
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
      # @board.state[pick[0]][pick[1]] = nil
      # This would not work, if piece still in place, because king check wont catch king openned to attack after move.
      # You can "nil" any figure except king. Or make a different logic.
      
      if king_not_in_danger?(@board.turn)
        @board.state[destination[0]][destination[1]] = piece_in_transit.dup
        transited_piece = @board.state[destination[0]][destination[1]]
        transited_piece.position = [destination[0], destination[1]]
        transited_piece.castling = false if transited_piece.castling

        case transited_piece.type
        when :king 
          transited_piece.colour == :white ? @white_king = destination : @black_king = destination
          if transited_piece.castling_coordinate.include?(destination)
            castling_direction = pick[1] - destination[1] > 0 ? :left_castling : :right_castling
            case castling_direction
            when :left_castling
              castling_rook = @board.state[destination[0]][0].dup
              @board.state[destination[0]][0] = nil
            when :right_castling
              castling_rook = @board.state[destination[0]][7].dup
              @board.state[destination[0]][7] = nil
            end
            @board.state[castling_rook.castling_coordinate[0]][castling_rook.castling_coordinate[1]] = castling_rook
            castling_rook.position = castling_rook.castling_coordinate
            castling_rook.castling = false
            castling_rook.castling_coordinate = []
          end
          transited_piece.castling_coordinate = []
        when :pawn 
          transited_piece.en_passant = true if [-2, 2].include?(pick[0] - destination[0])
          if (transited_piece.colour == :white && transited_piece.position[0] == 0) 
            || (transited_piece.colour == :black && transited_piece.position[0] == 7)
            transform_pawn(transited_piece.position, @board.state)  
          end
        end
        @board.state[pick[0]][pick[1]] = nil

        check_condition = transited_piece.get_moves(transited_piece.position, @board.state)
        if transited_piece.colour == :white && check_condition.include?(@black_king)
          @board.state[@black_king[0]][@black_king[1]].under_attack = true
          @black_king_attacked_by = [transited_piece.position[0], transited_piece.position[1]] 
        elsif transited_piece.colour == :black && check_condition.include?(@white_king)
          @board.state[@white_king[0]][@white_king[1]].under_attack = true
          @white_king_attacked_by = [transited_piece.position[0], transited_piece.position[1]] 
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

  def check_king_condition(king_position, board, pieces)
    x, y = king_position[0], king_position[1]
    condition = nil
    king_moves = board.state[x][y].get_moves([x, y], board.state)
    if board.state[x][y].under_attack
      condition = :check 
    elsif king_moves.empty?
      condition = :blocked
    else 
      condition = :free
    end

    if condition == :blocked && pieces.empty?
      condition = :stalemate
    elsif condition == :check && king_moves.empty?
      if pieces.empty?
        condition = :checkmate
      else
        condition = :checkmate if checkmate?(king_position, board, pieces)
      end
    end
    condition
  end

  def checkmate?(king_position, board, pieces)
    x, y = king_position[0], king_position[1]
    attacker = board.state[x][y].colour == :white ? @white_king_attacked_by : @black_king_attacked_by
    a, b = attacker[0], attacker[1]
    i, j = x <=> a, y <=> b
    trajectory = Array.new
    until [a, b] == [x, y]
      trajectory << [a, b]
      a += i
      b += j
    end
    result = true
    trajectory.each do |fragment|
      pieces.each do |piece|
        moves = board.state[piece[0]][piece[1]].get_moves(piece, board.state)
        if moves.include?(fragment)
          result = false
          break
        end
      end
      break if !result
    end
    result
  end

  def get_remaining_pieces(board, turn)
    pieces = []
    board.each do |row|
      row.each do |square|
        next if !square
        if square.colour == turn
          solve_en_passant(board, square) if square.en_passant
          pieces << square.position if board[square.position[0]][square.position[1]]
        end
      end
    end
    pieces
  end

  def solve_en_passant (board, square)
    square.colour == :white ? direction = 1 : direction = -1
    x, y = square.position[0], square.position[1]
    if board[x + direction][y] && board[x + direction][y].type == :pawn
      board[x][y] = nil
    else
      square.en_passant = false
    end
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
    check = turn == :white ? @white_king : @black_king
    array = @board.state[check[0]][check[1]].exclude_dangerous_king_moves([check], @board.state)
    result = !array.empty?
    result
  end

  def transform_pawn(position, board)
    x, y = position[0], position[1]
    player_choice = @ui.choose_piece
    @board[x][y] = Chess_piece.new(player_choice, board.turn, [x, y])
  end

end