class Board
  attr_accessor :board_state, :turn
  def initialize
    @board_state = Array.new(8, Array.new(8, nil))
    @turn = :white
  end
end