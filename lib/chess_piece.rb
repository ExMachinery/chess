require_relative 'board'
require_relative 'game'

class Chess_piece
  attr_accessor :type, :colour, :position, :en_passant, :castling, :under_attack
  def initialize(type, colour, position)
    @type = type
    @colour = colour
    @position = position
    @castling = true if type == :rook || type == :king
    @en_passant = nil
    @under_attack = false
  end

  def get_moves(position, board)
    moves = []
    a, b = position[0], position[1]
    case board[a][b].type
    when :pawn then moves = get_pawn_moves(position, board)
    when :rook then moves = get_rook_moves(position, board)
    when :knight then moves = get_knight_moves(position, board)
    when :bishop then moves = get_bishop_moves(position, board)
    when :queen then moves = get_queen_moves(position, board)
    when :king then moves = get_king_moves(position, board)
    end
    moves
  end
  
  def get_bishop_moves(position, board, used_by_king = false)
    for_king = false
    moves = []
    [1, -1].each do |i|
      [1, -1].each do |j|
        row, column = position[0], position[1]
        done = false
        until done
          row, column = row + i, column + j
          if row < 0 || row > 7 || column < 0 || column > 7
            done = true
            break
          end
          moves << [row, column] if board[row][column] == nil
          if !board[row][column].nil? && board[row][column].colour == self.colour
            done = true
          elsif !board[row][column].nil? && board[row][column].colour != self.colour
            done = true
            moves << [row, column]
            for_king = true if board[row][column].type == :bishop || board[row][column] == :queen
          end
        end
      end
    end
    return for_king if used_by_king
    moves
  end

  def get_rook_moves(position, board, used_by_king = false)
    for_king = false
    moves = []
    [1, -1].each do |i|
      skip_row_direction, skip_column_direction = false, false
      row, column = position[0], position[1]
      until skip_column_direction && skip_row_direction
        row = row + i if !skip_row_direction
        column = column + i if !skip_column_direction
        
        if row < 0 || row > 7
          skip_row_direction = true
        elsif !skip_row_direction
          moves << [row, position[1]] if board[row][position[1]] == nil
          if !board[row][position[1]].nil? && board[row][position[1]].colour == self.colour
            skip_row_direction = true
          elsif !board[row][position[1]].nil? && board[row][position[1]].colour != self.colour
            moves << [row, position[1]]
            for_king = true if board[row][position[1]].type == :rook || board[row][position[1]].type == :queen
            skip_row_direction = true
          end
        end

        if column < 0 || column > 7
          skip_column_direction = true
        elsif !skip_column_direction
          moves << [position[0], column] if board[position[0]][column] == nil
          if !board[position[0]][column].nil? && board[position[0]][column].colour == self.colour
            skip_column_direction = true
          elsif !board[position[0]][column].nil? && board[position[0]][column].colour != self.colour
            moves << [position[0], column]
            for_king = true if board[position[0]][column].type == :rook || board[position[0]][column].type == :queen
            skip_column_direction = true
          end
        end
      end
    end
    return for_king if used_by_king
    moves
  end

  def get_knight_moves(position, board, used_by_king = false)
    for_king = false
    row, column = position[0], position[1]
    moves = []
    [2, -2].each do |i|
      [1, -1].each do |j|
        a, b = row + i, column + j
        if a >= 0 && a <= 7 && b >= 0 && b <= 7
          if board[a][b].nil? || board[a][b].colour != self.colour
            moves << [a, b] 
            for_king = true if !board[a][b].nil? && board[a][b].type == :knight
          end
        end

        a, b = row + j, column + i
        if a >= 0 && a <= 7 && b >= 0 && b <= 7
          if board[a][b].nil? || board[a][b].colour != self.colour
            moves << [a, b]
            for_king = true if !board[a][b].nil? && board[a][b].type == :knight
          end
        end    
      end
    end
    return for_king if used_by_king
    moves
  end

  def get_pawn_moves(position, board)
    moves = []
    row, column = position[0], position[1]
    self.colour == :white ? direction = -1 : direction = 1

    #Moving forward
    if board[row + direction][column].nil?
      moves << [row + direction, column] if row + direction >= 0 && row + direction <= 7
      if row == 1 || row == 6
        moves << [row + (2*direction), column] if board[row + (2*direction)][column].nil? 
      end
    end

    #Standard diagonal attack
    if !board[row + direction][column + direction].nil? && board[row + direction][column + direction].colour != self.colour
      moves << [row + direction, column + direction]
    elsif !board[row + direction][column - direction].nil? && board[row + direction][column - direction].colour != self.colour
      moves << [row + direction, column - direction]
    end

    #En passant
    # if !board[row][column + 1].nil? && board[row][column + 1].colour != self.colour && board[row][column + 1].en_passant == true
    #   moves << [row + direction, column + direction] 
    # end
    # if !board[row][column - 1].nil? && board[row][column - 1].colour != self.colour && board[row][column - 1].en_passant == true
    #   moves << [row + direction, column - direction] 
    # end   
    # moves

    #En_passant2
    [-1, 1].each do |side|
      if !board[row][column + side].nil? && board[row][column + side].colour != self.colour && board[row][column + side].en_passant
        moves << [row + direction, column + side]
      end
    end
    moves

  end

  def get_king_moves(position, board, used_by_king = false)
    for_king = false
    moves = []
    row, column = position[0], position[1]
    (-1..1).each do |i|
      (-1..1).each do |j|
        next if i == 0 && j == 0
        a, b = row + i, column + j
        next if a < 0 || a > 7 || b < 0 || b > 7
        if board[a][b].nil? || board[a][b].colour != self.colour
          moves << [a, b]
          for_king = true if !board[a][b].nil? && board[a][b].type == :king
        end
      end
    end
    return for_king if used_by_king

    if self.castling && !self.under_attack
      castling_position = check_castling(position, board)
      if castling_position
        moves << castling_position
        # Here castling position could be sent to Game for additional UI features
      end
    end

    final_moves = exclude_dangerous_king_moves(moves, board)
    final_moves
  end

  def check_castling(position, board)
    castling_position = []
    check_on_left, check_on_right = false, false
    row, column = position[0], position[1]
    i = 1
    until check_on_left && check_on_right
      left = column + i if !check_on_left
      right = column - i if !check_on_right
      
      if left >= 0 && left <= 7 && !board[row][left].nil? && !board[row][left].castling
        check_on_left = true
      elsif !board[row][left].nil? && board[row][left].castling
        castling_position = [row, column + 2] 
        check_on_left = true
      end

      if right >= 0 && right <= 7 && !board[row][right].nil? && !board[row][right].castling
        check_on_right = true
      elsif !board[row][right].nil? && board[row][right].castling
        castling_position = [row, column - 2] 
        check_on_right = true
      end
      i += 1
    end
    castling_position
  end

  def exclude_dangerous_king_moves(moves, board)
    final_moves = moves.dup
    moves.each do |move|
      if get_bishop_moves(move, board, true) || get_knight_moves(move, board, true) 
        || get_rook_moves(move, board, true) || get_king_moves(move, board, true)
        final_moves.delete(move)
      end

      # Excluding squares under attack by enemy pawns
      row, column = move[0], move[1]
      self.colour == :white ? direction = -1 : direction = 1
      if !board[row + direction][column + 1].nil? && board[row + direction][column + 1].type == :pawn
        final_moves.delete(move) if board[row + direction][column + 1].colour == :black 
      end
      if !board[row + direction][column - 1].nil? && board[row + direction][column - 1].type == :pawn
        final_moves.delete(move) if board[row + direction][column - 1].colour == :black 
      end
    end
    final_moves
  end

  def get_queen_moves(position, board)
    moves = []
    moves += get_rook_moves(position, board)
    moves += get_bishop_moves(position, board)
    moves
  end
end