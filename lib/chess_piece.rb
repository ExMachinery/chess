require_relative 'board'
require_relative 'game'

class Chess_piece
  attr_accessor :type, :colour, :position, :en_passant, :castling
  def initialize(type, colour, position)
    types = [:pawn, :rock, :knight, :bishop, :queen, :king]
    @type = type
    @colour = colour
    @position = position
    @castling = true if type == :rock || type == :king
    @queue = []
    @en_passant = nil
  end

  def get_bishop_moves(position, board)
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
          end
        end
      end
    end
    moves
  end

  def get_rock_moves(position, board)
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
            #======
            # Here could be castling logic, if there is white king with @castling == true
            # This particular set of coordinates could be sent to Game as a "Castling" variant
            # which could be suggested to player as a variant.
            # =====
          elsif !board[row][position[1]].nil? && board[row][position[1]].colour != self.colour
            moves << [row, position[1]]
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
            skip_column_direction = true
          end
        end
      end
    end
    moves
  end

  def get_knight_moves(position, board)
    row, column = position[0], position[1]
    moves = []
    [2, -2].each do |i|
      [1, -1].each do |j|
        a, b = row + i, column + j
        if a >= 0 && a <= 7 && b >= 0 && b <= 7
          moves << [a, b] if board[a][b].nil? || board[a][b].colour != self.colour
        end

        a, b = row + j, column + i
        if a >= 0 && a <= 7 && b >= 0 && b <= 7
          moves << [a, b] if board[a][b].nil? || board[a][b].colour != self.colour
        end       
      end
    end
    moves
  end

  def get_pawn_moves(position, board)
    moves = []
    row, column = position[0], position[1]
    self.colour == :white ? direction = 1 : direction = -1

    #Moving forward
    if board[row + direction][column].nil?
      moves << [row + direction, column] if row + direction >= 0 && row + direction <= 7
      if row == 1 || row == 6
        moves << [row + (2*direction), column] if board[row + (2*direction)][column].nil? 
                                                  && row + (2*direction) >= 0 && row + (2*direction) <= 7
      end
    end

    #Standard diagonal attack
    if !board[row + direction][column + direction].nil? && board[row + direction][column + direction].colour != self.colour
      moves << [row + direction, column + direction]
    elsif !board[row + direction][column - direction].nil? && board[row + direction][column - direction].colour != self.colour
      moves << [row + direction, column - direction]
    end

    #En passant
    if !board[row][column + 1].nil? && board[row][column + 1].colour != self.colour && board[row][column + 1].en_passant == true
      moves << [row + direction, column + direction] if board[row + direction][column + direction].nil?
    end
    if !board[row][column - 1].nil? && board[row][column - 1].colour != self.colour && board[row][column - 1].en_passant == true
      moves << [row + direction, column - direction] if board[row + direction][column - direction].nil?
    end
    moves = nil if moves.empty?
    moves
  end

  def get_queen_moves(position, board)
    moves = []
    moves += get_rock_moves(position, board)
    moves += get_bishop_moves(position, board)
    moves
  end
end