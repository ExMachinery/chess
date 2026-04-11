require_relative 'board'
require_relative 'player'
require_relative 'ui'
require_relative 'chess_piece'

class Game
  attr_accessor :ui, :board, :p1, :p2, :white_king, :black_king, :white_king_attacked_by, :black_king_attacked_by
  def initialize(instruction = nil)
    if instruction == :test # Delete this when done
      @ui = UI.new
      @board = Board.new(@ui, self)
      @p1 = Player.new("Big Beaver", :white)
      @p2 = Player.new("Small Beaver", :black)
    else
      @ui = UI.new
      @board = Board.new
      # Load save game logic here
      @board.prepare_for_new_game
      @white_king = [7, 4]
      @black_king = [0, 4]
      @white_king_attacked_by = nil
      @black_king_attacked_by = nil
      player_nicknames = @ui.get_new_players_name
      @p1 = Player.new(player_nicknames[0], :white)
      @p2 = Player.new(player_nicknames[1], :black)
    end
  end

  def game_sequence_start
    done = false
    until done
      pieces = get_remaining_pieces(@board.state, @board.turn)

      # Get king condition in this turn
      king_position = @board.turn == :white ? @white_king : @black_king
      king_condition = check_king_condition(king_position, @board, pieces)

      # Get player valid pick and destination.
      case king_condition
      when :free, :blocked, :check
        passed = false
        until passed
          decision = process_player_decision(@board.state, pieces)
          pick, destination = decision[0], decision[1]
          passed = process_temporary_state(pick, destination, pieces, @board.state)
        end

        transited_piece = @board.state[destination[0]][destination[1]]
        manage_transit(@board.state, pick, destination, transited_piece)
        detect_check_condition(@board.state, transited_piece)
        @board.turn = @board.turn == :white ? :black : :white
        @board.fullmove += 1 if @board.turn == :white && @board.fullmove != 1
        @board.process_draw_condition
      when :stalemate, :draw_by_halfmove_rule
        # Draw condition
        @ui.render_board(@board.state)
        result = king_condition == :stalemate ? "Stalemate. Draw!" : "Draw by halfmove rule!"
        puts "#{result}"
        system("exit")
        break
      when :checkmate
        # Winning condition
        @ui.render_board(@board.state)
        winner = @white_king_attacked_by ? "White" : "Black"
        puts "Checkmate. #{winner} is won!"
        system("exit")
        break
      end
    end
  end

  def process_temporary_state(pick, destination, pieces, board)
    p_x, p_y = pick[0], pick[1]
    d_x, d_y = destination[0], destination[1]

    piece_in_transit = board[p_x][p_y].dup
    square_condition = board[d_x][d_y].dup
    colour = piece_in_transit.colour
    if piece_in_transit.type == :king
      colour == :white ? @white_king = [d_x, d_y] : @black_king = [d_x, d_y] # Reverse needed: C
    end
    board[d_x][d_y] = piece_in_transit.dup # Reverse needed: A
    board[p_x][p_y] = nil # Reverse needed: B
    
    ### En passant rare case, where king protected from check by enemy pawn solution
    enemy_pawn = nil
    if piece_in_transit.type == :pawn && p_y != d_y
      enemy_pawn = board[p_x][d_y].dup
      board[p_x][d_y] = nil # Reverse needed: E
    end
    ###

    passed = inspect_check_condition(@board)
    board[p_x][d_y] = enemy_pawn if enemy_pawn # Reversed: E
    if !passed
      board[p_x][p_y] = piece_in_transit # Reversed: B
      board[d_x][d_y] = square_condition # Reversed: A
      if piece_in_transit.type == :king
        colour == :white ? @white_king = [p_x, p_y] : @black_king = [p_x, p_y] # Reversed: C
      end
      @ui.clear
      @ui.alert_king_is_vulnerable
    end
    passed
  end

  def detect_check_condition(board, transited_piece)
    check_condition = transited_piece.get_moves(transited_piece.position, board)
    if transited_piece.colour == :white && check_condition.include?(@black_king)
      board[@black_king[0]][@black_king[1]].under_attack = true
      @black_king_attacked_by = transited_piece.position.dup
    elsif transited_piece.colour == :black && check_condition.include?(@white_king)
      board[@white_king[0]][@white_king[1]].under_attack = true
      @white_king_attacked_by = transited_piece.position.dup
    end    
  end

  def inspect_check_condition(board)
    inspection_result = false
    king = board.turn == :white ? @white_king : @black_king
    x, y = king[0], king[1]
    king_check = board.state[x][y].exclude_dangerous_king_moves([[x, y]], board.state)
    if !king_check.empty?
      board.state[x][y].under_attack = false
      board.state[x][y].colour == :white ? @white_king_attacked_by = nil : @black_king_attacked_by = nil
      inspection_result = true
    end
    inspection_result
  end

  def manage_transit(board, pick,  destination, transited_piece)
    x, y = destination[0], destination[1]
    transited_piece.position = [x, y]
    transited_piece.castling = false if transited_piece.castling
    case transited_piece.type
    when :king 
      transited_piece.colour == :white ? @white_king = destination : @black_king = destination
      if transited_piece.castling_coordinate.include?(destination)
        castling_direction = pick[1] - y > 0 ? :left_castling : :right_castling
        case castling_direction
        when :left_castling
          castling_rook = board[x][0].dup
          board[x][0] = nil
        when :right_castling
          castling_rook = board[x][7].dup
          board[x][7] = nil
        end
        board[castling_rook.castling_coordinate[0]][castling_rook.castling_coordinate[1]] = castling_rook
        castling_rook.position = castling_rook.castling_coordinate
        castling_rook.castling = false
        castling_rook.castling_coordinate = []
      end
      transited_piece.castling_coordinate = []
      board[pick[0]][pick[1]] = nil
    when :pawn
      @board.halfmove = 0
      transited_piece.en_passant = true if [-2, 2].include?(pick[0] - x)
      if (transited_piece.colour == :white && transited_piece.position[0] == 0) 
        || (transited_piece.colour == :black && transited_piece.position[0] == 7)
        transform_pawn(transited_piece.position, board)  
      end
    end
  end

  # Get player valid pick and destination.
  def process_player_decision(board, pieces)
    destination, pick, moves = nil, nil, nil
    until destination
      transition = ensure_transition(pieces)
      pick, moves = transition[0], transition[1]
      if pick == :exit
        # Here check for "Exit & Save the game" needed
        system("exit") # Temporary
      end
      
      @ui.clear
      @ui.render_board(board, moves)

      destination = false
      destination = @ui.get_player_move(moves, board)
    end
    return [pick, destination]
  end

  def check_king_condition(king_position, board, pieces)
    x, y = king_position[0], king_position[1]
    condition = nil
    king_moves = board.state[x][y].get_moves([x, y], board.state)
    king_in_danger = board.state[x][y].exclude_dangerous_king_moves([x, y], board.state)
    if king_in_danger.empty?
      condition = :check
    elsif king_moves.empty?
      condition = :blocked
    else 
      condition = :free
    end

    pieces_minus_king = pieces.reject {|piece| piece == [x, y]}
    if condition == :blocked
      if pieces_minus_king.empty?
        condition = :stalemate 
      else
        moves = nil
        pieces_minus_king.each do |piece|
          moves = board.state[piece[0]][piece[1]].get_moves([piece[0], piece[1]], board.state)
          break if !moves.empty?
        end
        condition = :stalemate if moves.empty?
      end
    elsif condition == :check && king_moves.empty?
      if pieces.empty?
        condition = :checkmate
      else
        condition = :checkmate if checkmate?(king_position, board, pieces)
      end
    end
    condition = :draw_by_halfmove_rule if board.halfmove > 100
    condition
  end

  def checkmate?(king_position, board, pieces)
    trajectory = Array.new
    x, y = king_position[0], king_position[1]
    attacker = board.state[x][y].colour == :white ? @white_king_attacked_by : @black_king_attacked_by
    a, b = attacker[0], attacker[1]
    if board.state[a][b].type == :knight
      trajectory << [a, b]
    else
      i, j = x <=> a, y <=> b
      until [a, b] == [x, y]
        trajectory << [a, b]
        a += i
        b += j
      end
    end

    # King is blocked?
    king_moves = board.state[x][y].get_moves([x, y], board.state)
    if king_moves.empty?
      board.state[x][y].mark_deffenders(king_position, board.state)
    end

    result = true
    trajectory.each do |fragment|
      pieces.each do |piece|
        next if board.state[piece[0]][piece[1]].type == :king
        next if board.state[piece[0]][piece[1]].king_deffender
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
          if square.en_passant
            solve_en_passant(board, square)
            next
          end
          square.king_deffender = nil if square.king_deffender
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
      @ui.alert_check if @board.state[@white_king[0]][@white_king[1]].under_attack || @board.state[@black_king[0]][@black_king[1]].under_attack
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

  def transform_pawn(position, board)
    x, y = position[0], position[1]
    player_choice = @ui.choose_piece
    board[x][y] = Chess_piece.new(player_choice, @board.turn, [x, y])
  end
end