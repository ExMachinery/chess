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
  end
end