require_relative 'chess_piece'
class Board
  attr_accessor :state, :turn
  def initialize
    @state = Array.new(8) { Array.new(8, nil) }
    @turn = :white
  end

  def prepare_for_new_game
    # 8.times do |num|
    #   @state[1][num] = Chess_piece.new(:pawn, :black, [1, num])
    #   @state[6][num] = Chess_piece.new(:pawn, :white, [6, num])
    # end
    
    2.times do |num|
      num == 0 ? side = 0 : side = 7
      num == 0 ? colour = :black : colour = :white
      @state[side][0] = Chess_piece.new(:rook, colour, [side, 0])
      @state[side][7] = Chess_piece.new(:rook, colour, [side, 7])
      # @state[side][1] = Chess_piece.new(:knight, colour, [side, 1])
      # @state[side][6] = Chess_piece.new(:knight, colour, [side, 6])
      # @state[side][2] = Chess_piece.new(:bishop, colour, [side, 2])
      # @state[side][5] = Chess_piece.new(:bishop, colour, [side, 5])
      # @state[side][3] = Chess_piece.new(:queen, colour, [side, 3])
      @state[side][4] = Chess_piece.new(:king, colour, [side, 4])
    end
  end
end


