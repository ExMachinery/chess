require_relative 'chess_piece'
class Board
  attr_accessor :board, :turn
  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
    @turn = :white
    types = [:pawn, :rook, :knight, :bishop, :queen, :king]
  end

  def prepare_for_new_game
    8.times do |num|
      @board[1][num] = Chess_piece.new(:pawn, :black, [1, num])
      @board[6][num] = Chess_piece.new(:pawn, :white, [6, num])
    end
    
    2.times do |num|
      num == 0 ? side = 0 : side = 7
      num == 0 ? colour = :black : colour = :white
      @board[side][0] = Chess_piece.new(:rook, colour, [side, 0])
      @board[side][7] = Chess_piece.new(:rook, colour, [side, 7])
      @board[side][1] = Chess_piece.new(:knight, colour, [side, 1])
      @board[side][6] = Chess_piece.new(:knight, colour, [side, 6])
      @board[side][2] = Chess_piece.new(:bishop, colour, [side, 2])
      @board[side][5] = Chess_piece.new(:bishop, colour, [side, 5])
      @board[side][3] = Chess_piece.new(:queen, colour, [side, 3])
      @board[side][4] = Chess_piece.new(:king, colour, [side, 4])
    end
  end
end


