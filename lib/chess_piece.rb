require_relative 'board'
require_relative 'game'

class Chess_piece
  attr_accessor :type, :colour, :position, :en_passant, :castling, :under_attack, :castling_coordinate, :king_deffender
  def initialize(type, colour, position)
    @type = type
    @colour = colour
    @position = position
    @castling = true if type == :rook || type == :king
    @en_passant = nil
    @under_attack = false
    @castling_coordinate = []
    @king_deffender = nil
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
  
  def get_bishop_moves(position, board, instruction = false)
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
            for_king = true if board[row][column].type == :bishop || board[row][column].type == :queen
          end
        end
      end
    end
    return for_king if instruction == :for_king
    moves
  end

  def mark_deffenders(position, board)
    mark_bishop_deffender(position, board)
    mark_rook_deffender(position, board)
  end

  def mark_bishop_deffender(position, board)
    [1, -1].each do |i|
      [1, -1].each do |j|
        row, column = position[0], position[1]
        deffender = nil
        done = false
        until done
          row, column = row + i, column + j
          if row < 0 || row > 7 || column < 0 || column > 7
            done = true
            break
          end
          next if board[row][column] == nil
          if !board[row][column].nil? && board[row][column].colour == self.colour
            done = true if deffender
            deffender = board[row][column]
          elsif !board[row][column].nil? && board[row][column].colour != self.colour
            if board[row][column].type == :bishop || board[row][column].type == :queen
              board[deffender.position[0]][deffender.position[1]].king_deffender = true if deffender
            end
            done = true
          end
        end
      end
    end
  end

  def get_rook_moves(position, board, instruction = false)
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
    return for_king if instruction == :for_king
    moves
  end

  def mark_rook_deffender(position, board)
    [1, -1].each do |i|
      h_deffender, v_deffender = nil
      skip_row_direction, skip_column_direction = false, false
      row, column = position[0], position[1]
      until skip_column_direction && skip_row_direction
        row = row + i if !skip_row_direction
        column = column + i if !skip_column_direction
        
        # Vertical check
        if row < 0 || row > 7
          skip_row_direction = true
        elsif !skip_row_direction
          if !board[row][position[1]].nil? && board[row][position[1]].colour == self.colour
            skip_row_direction = true if v_deffender
            v_deffender = board[row][position[1]]
          elsif !board[row][position[1]].nil? && board[row][position[1]].colour != self.colour
            if board[row][position[1]].type == :rook || board[row][position[1]].type == :queen
              board[v_deffender.position[0]][v_deffender.position[1]].king_deffender = true if v_deffender
            end
            skip_row_direction = true
          end
        end
        
        # Horisontal check
        if column < 0 || column > 7
          skip_column_direction = true
        elsif !skip_column_direction
          if !board[position[0]][column].nil? && board[position[0]][column].colour == self.colour
            skip_column_direction = true if h_deffender
            h_deffender = board[position[0]][column]
          elsif !board[position[0]][column].nil? && board[position[0]][column].colour != self.colour
            if board[position[0]][column].type == :rook || board[position[0]][column].type == :queen
              board[h_deffender.position[0]][h_deffender.position[1]].king_deffender = true if h_deffender
            end
            skip_column_direction = true
          end
        end
      end
    end
  end

  def get_knight_moves(position, board, instruction = false)
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
    return for_king if instruction == :for_king
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
    [-1, 1].each do |side|
      if !board[row + direction][column + side].nil? && board[row + direction][column + side].colour != self.colour
        moves << [row + direction, column + side]
      end
    end

    #En_passant
    [-1, 1].each do |side|
      if !board[row][column + side].nil? && board[row][column + side].colour != self.colour && board[row][column + side].en_passant
        moves << [row + direction, column + side]
      end
    end
    moves

  end

  def get_king_moves(position, board, instruction = false)
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
    return for_king if instruction == :for_king

    if self.castling && !self.under_attack
      check_castling(position, board)
    end

    final_moves = exclude_dangerous_king_moves(moves, board)
    final_moves += @castling_coordinate
    final_moves
  end

  def check_castling(positon, board)
    @castling_coordinate = []
    king_x, king_y = position[0], position[1]
    left, right = true, true

    if board[king_x][0] && board[king_x][0].castling
      board[king_x][0].castling_coordinate = []
      i = 1
      until i == king_y || !left
        left = false if board[king_x][i]
        i += 1
      end
    end
    if board[king_x][7] && board[king_x][7].castling
      board[king_x][7].castling_coordinate = []
      i = 6
      until i == king_y || !right
        right = false if board[king_x][i]
        i -= 1
      end
    end

    if left
      rook_castling_position = [king_x, king_y - 1]
      king_castling_position = [king_x, king_y - 2]
      if exclude_dangerous_king_moves([rook_castling_position, king_castling_position], board).size == 2
        @castling_coordinate << king_castling_position
        board[king_x][0].castling_coordinate = rook_castling_position
      end
    end
    if right
      king_castling_position = [king_x, king_y + 2]
      rook_castling_position = [king_x, king_y + 1]
      if exclude_dangerous_king_moves([rook_castling_position, king_castling_position], board).size == 2
        @castling_coordinate << king_castling_position
        board[king_x][7].castling_coordinate = rook_castling_position
      end
    end
  end

  def exclude_dangerous_king_moves(moves, board)
    final_moves = moves.dup
    moves.each do |move|
      puts "bishop: #{get_bishop_moves(move, board, :for_king)}, knight: #{get_knight_moves(move, board, :for_king)}, rook: #{get_rook_moves(move, board, :for_king)}, king: #{get_king_moves(move, board, :for_king)}"
      if get_bishop_moves(move, board, :for_king) || get_knight_moves(move, board, :for_king) 
        || get_rook_moves(move, board, :for_king) || get_king_moves(move, board, :for_king)
        final_moves.delete(move)
      end
      # Excluding squares under attack by enemy pawns
      row, column = move[0], move[1]
      self.colour == :white ? direction = -1 : direction = 1
      enemy_colour = self.colour == :white ? :black : :white
      if !board[row + direction][column + 1].nil? && board[row + direction][column + 1].type == :pawn
        final_moves.delete(move) if board[row + direction][column + 1].colour == enemy_colour
      end
      if !board[row + direction][column - 1].nil? && board[row + direction][column - 1].type == :pawn && column - 1 > 0
        final_moves.delete(move) if board[row + direction][column - 1].colour == enemy_colour
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