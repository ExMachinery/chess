require './lib/game'

RSpec.describe Game do
  subject {Game.new(:test)}
  describe "#checkmate?" do
    it "correctly identify checkmate" do
      subject.board = Board.new
      subject.board.state[0][0] = Chess_piece.new(:king, :white, [0, 0])
      subject.board.state[7][1] = Chess_piece.new(:rook, :black, [7, 1])
      subject.board.state[3][3] = Chess_piece.new(:bishop, :black, [3, 3])
      subject.white_king_attacked_by = [3, 3]
      subject.board.state[1][7] = Chess_piece.new(:rook, :black, [1, 7])
      subject.board.state[5][3] = Chess_piece.new(:pawn, :white, [5, 3])
      expect(subject.checkmate?([0, 0], subject.board, [[5, 3]])).to eql(true)
    end

    it "correctly identify check with deffendable blocked king" do
      subject.board = Board.new
      subject.board.state[0][0] = Chess_piece.new(:king, :white, [0, 0])
      subject.board.state[7][1] = Chess_piece.new(:rook, :black, [7, 1])
      subject.board.state[3][3] = Chess_piece.new(:bishop, :black, [3, 3])
      subject.white_king_attacked_by = [3, 3]
      subject.board.state[1][7] = Chess_piece.new(:rook, :black, [1, 7])
      subject.board.state[5][3] = Chess_piece.new(:pawn, :white, [5, 3])
      subject.board.state[0][1] = Chess_piece.new(:rook, :white, [0, 1])
      expect(subject.checkmate?([0, 0], subject.board, [[5, 3], [0, 1]])).to eql(false)      
    end

  end
end