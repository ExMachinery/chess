require_relative 'board'
require_relative 'game'

class Chess_piece
  attr_accessor :type, :colour, :position, :en_passant, :castiling
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

end