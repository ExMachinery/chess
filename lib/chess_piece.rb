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
  end

  def get_pawn_moves
    
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
        else
          moves << [row, position[1]] if board[row][position[1]] == nil
          if !board[row][position[1]].nil? && board[row][position[1]].colour == self.colour
            skip_row_direction = true
          elsif !board[row][position[1]].nil? && board[row][position[1]].colour != self.colour
            moves << [row, position[1]]
            skip_row_direction = true
          end
        end

        if column < 0 || column > 7
          skip_column_direction = true
        else
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

end