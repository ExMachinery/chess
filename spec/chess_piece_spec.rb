require './lib/chess_piece'

RSpec.describe Chess_piece do
  let(:board) { Array.new(8) {Array.new(8, nil)}}
  let(:test) { Chess_piece.new(:bishop, :white, [3, 1])}
  describe "#get_bishop_moves" do
    it "returns correct moves" do
      board[3][1] = Chess_piece.new(:pawn, :white, [1, 3])
      board[3][5] = Chess_piece.new(:pawn, :black, [5, 3])
      expect(test.get_bishop_moves([1, 3], board)).to eql([[2, 4], [3, 5], [2, 2], [0, 4], [0, 2]])
    end
  end
end