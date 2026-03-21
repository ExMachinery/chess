require './lib/chess_piece'

RSpec.describe Chess_piece do
  let(:board) { Array.new(8) {Array.new(8, nil)}}
  describe "#get_bishop_moves" do
    it "returns correct moves" do
      test = Chess_piece.new(:bishop, :white, [3, 1])
      board[3][1] = Chess_piece.new(:pawn, :white, [1, 3])
      board[3][5] = Chess_piece.new(:pawn, :black, [5, 3])
      expect(test.get_bishop_moves([1, 3], board)).to eql([[2, 4], [3, 5], [2, 2], [0, 4], [0, 2]])
    end
  end

  describe "#get_rock_moves" do
    it "returns correct moves" do
      test = Chess_piece.new(:rock, :white, [1, 1])
      board[3][1] = Chess_piece.new(:pawn, :black, [3, 1])
      board[1][3] = Chess_piece.new(:pawn, :white, [1, 3])
      expect(test.get_rock_moves([1, 1], board)).to eql([[2, 1], [1, 2], [3, 1], [0, 1], [1, 0]])
    end
  end

  describe " #get_knight_moves" do
    it "returns correct moves" do
      test = Chess_piece.new(:knight, :white, [1, 1])
      board[0][3] = Chess_piece.new(:pawn, :white, [0, 3])
      board[2][3] = Chess_piece.new(:pawn, :blach, [2, 3])
      expect(test.get_knight_moves([1, 1], board)).to eql([[3, 2], [2, 3], [3, 0]])
    end
  end
end