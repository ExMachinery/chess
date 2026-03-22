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
      test = Chess_piece.new(:rook, :white, [1, 1])
      board[3][1] = Chess_piece.new(:pawn, :black, [3, 1])
      board[1][3] = Chess_piece.new(:pawn, :white, [1, 3])
      expect(test.get_rook_moves([1, 1], board)).to eql([[2, 1], [1, 2], [3, 1], [0, 1], [1, 0]])
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

  describe " #get_queen_moves" do
    it "return correct moves" do
      test = Chess_piece.new(:queen, :white, [1, 1])
      board[1][3] = Chess_piece.new(:pawn, :white, [1, 3])
      board[3][3] = Chess_piece.new(:pawn, :white, [3, 3])
      board[2][1] = Chess_piece.new(:pawn, :black, [2, 1])
      expect(test.get_queen_moves([1, 1], board)).to eql([[2, 1], [1, 2], [0, 1], [1, 0], [2, 2], [2, 0], [0, 2], [0, 0]])
    end
  end

  describe " #get_pawn_moves" do
    it "can go 1 or 2 squares form starting position and eat by diagonal" do
      test = Chess_piece.new(:pawn, :white, [1, 1])
      board[2][0] = Chess_piece.new(:pawn, :black, [2, 0])
      expect(test.get_pawn_moves([1, 1], board)).to eql([[2, 1], [3, 1], [2, 0]])
    end

    it "cant go through alied pieces and can eat enemy pawn en passant" do
      test = Chess_piece.new(:pawn, :white, [1, 1])
      board[1][0] = Chess_piece.new(:pawn, :black, [1, 0])
      board[1][0].en_passant = true
      board[2][1] = Chess_piece.new(:pawn, :white, [2, 1])
      expect(test.get_pawn_moves([1, 1], board)).to eql([[2, 0]])
    end

    it "cant go through enemy pieces and eat enemy pawn without en passant" do
      test = Chess_piece.new(:pawn, :white, [1, 1])
      board[1][0] = Chess_piece.new(:pawn, :black, [1, 0])
      board[2][1] = Chess_piece.new(:pawn, :black, [2, 1])
      expect(test.get_pawn_moves([1, 1], board)).to eql(nil)
    end
  end

  describe " #get_king_moves" do
    it "could calculate valid moves excluding under attack squares" do
      test = Chess_piece.new(:king, :white, [1, 1])
      test.castling = false
      board[0][0] = Chess_piece.new(:rook, :black, [0, 0])
      board[1][0] = Chess_piece.new(:pawn, :black, [1, 0])
      board[0][2] = Chess_piece.new(:pawn, :white, [0, 2])
      board[1][2] = Chess_piece.new(:pawn, :black, [1, 2])
      board[1][4] = Chess_piece.new(:knight, :black, [1, 4])
      board[7][5] = Chess_piece.new(:bishop, :black, [7, 5])
      expect(test.get_king_moves([1, 1], board)).to eql([[0, 0], [1, 2]])
    end

    it "could calculate valid moves against king and allow castling" do
      test = Chess_piece.new(:king, :white, [0, 3])
      board[0][0] = Chess_piece.new(:rook, :white, [0, 0])
      board[0][6] = Chess_piece.new(:knight, :white, [0, 6])
      board[0][7] = Chess_piece.new(:rook, :white, [0, 7])
      board[2][3] = Chess_piece.new(:king, :black, [2, 3])
      expect(test.get_king_moves([0, 3], board)).to eql([[0, 2], [0, 4], [0, 1]])
    end


  end

end