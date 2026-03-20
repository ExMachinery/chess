require_relative 'chess_piece'
class Board
  attr_accessor :board, :turn
  def initialize
    @board = Array.new(8) { Array.new(8, nil) }
    @turn = :white
    types = [:pawn, :rock, :knight, :bishop, :queen, :king]
  end

  def prepare_for_new_game
    8.times do |num|
      @board[1][num] = Chess_piece.new(:pawn, :black, [1, num])
      @board[6][num] = Chess_piece.new(:pawn, :white, [6, num])
    end
    
    2.times do |num|
      num == 0 ? side = 0 : side = 7
      num == 0 ? colour = :black : colour = :white
      @board[side][0] = Chess_piece.new(:rock, colour, [0, side])
      @board[side][7] = Chess_piece.new(:rock, colour, [7, side])
      @board[side][1] = Chess_piece.new(:knight, colour, [1, side])
      @board[side][6] = Chess_piece.new(:knight, colour, [6, side])
      @board[side][2] = Chess_piece.new(:bishop, colour, [2, side])
      @board[side][5] = Chess_piece.new(:bishop, colour, [5, side])
      @board[side][3] = Chess_piece.new(:queen, colour, [3, side])
      @board[side][4] = Chess_piece.new(:king, colour, [4, side])
    end
  end
end


