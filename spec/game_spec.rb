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

  describe "#check_king_condition" do
    it "correctly identify checkmate" do
      subject.board = Board.new
      subject.board.state[0][0] = Chess_piece.new(:king, :white, [0, 0])
      subject.board.state[0][0].under_attack = true
      subject.board.state[7][1] = Chess_piece.new(:rook, :black, [7, 1])
      subject.board.state[3][3] = Chess_piece.new(:bishop, :black, [3, 3])
      subject.white_king_attacked_by = [3, 3]
      subject.board.state[1][7] = Chess_piece.new(:rook, :black, [1, 7])
      subject.board.state[5][3] = Chess_piece.new(:pawn, :white, [5, 3])
      expect(subject.check_king_condition([0, 0], subject.board, [[5, 3]])).to eql(:checkmate)
    end

    it "correctly identify check on blocked, but defendable king" do
      subject.board = Board.new
      subject.board.state[0][0] = Chess_piece.new(:king, :white, [0, 0])
      subject.board.state[7][1] = Chess_piece.new(:rook, :black, [7, 1])
      subject.board.state[3][3] = Chess_piece.new(:bishop, :black, [3, 3])
      subject.board.state[0][0].under_attack = true
      subject.white_king_attacked_by = [3, 3]
      subject.board.state[1][7] = Chess_piece.new(:rook, :black, [1, 7])
      subject.board.state[5][3] = Chess_piece.new(:pawn, :white, [5, 3])
      subject.board.state[0][1] = Chess_piece.new(:rook, :white, [0, 1])
      expect(subject.check_king_condition([0, 0], subject.board, [[5, 3], [0, 1]])).to eql(:check)
    end

    it "correctly identify stalemate" do
      subject.board = Board.new
      subject.board.state[0][0] = Chess_piece.new(:king, :white, [0, 0])
      subject.board.state[0][0].castling = false
      subject.board.state[7][1] = Chess_piece.new(:rook, :black, [7, 1])
      subject.board.state[1][7] = Chess_piece.new(:rook, :black, [1, 7])
      expect(subject.check_king_condition([0, 0], subject.board, [])).to eql(:stalemate)      
    end

    it "correctly identify simple check condition" do
      subject.board = Board.new
      subject.board.state[0][0] = Chess_piece.new(:king, :white, [0, 0])
      subject.board.state[0][0].castling = false
      subject.board.state[0][0].under_attack = true
      subject.white_king_attacked_by = [0, 7]
      subject.board.state[7][1] = Chess_piece.new(:rook, :black, [7, 1])
      subject.board.state[0][7] = Chess_piece.new(:rook, :black, [0, 7])
      expect(subject.check_king_condition([0, 0], subject.board, [])).to eql(:check)        
    end

    it "correctly identify free king, who has atleast 1 save move" do
      subject.board = Board.new
      subject.board.state[0][0] = Chess_piece.new(:king, :white, [0, 0])
      subject.board.state[0][0].castling = false
      subject.board.state[7][1] = Chess_piece.new(:rook, :black, [7, 1])
      expect(subject.check_king_condition([0, 0], subject.board, [])).to eql(:free)        
    end

    it "correctly identify blocked king, who is not in danger" do
      subject.board = Board.new
      subject.board.state[0][0] = Chess_piece.new(:king, :white, [0, 0])
      subject.board.state[0][0].castling = false
      subject.board.state[7][1] = Chess_piece.new(:rook, :black, [7, 1])
      subject.board.state[1][7] = Chess_piece.new(:rook, :black, [1, 7])
      subject.board.state[7][0] = Chess_piece.new(:rook, :black, [7, 0])
      subject.board.state[0][7] = Chess_piece.new(:rook, :black, [0, 7])
      subject.board.state[0][1] = Chess_piece.new(:knight, :white, [0, 1])
      subject.board.state[1][0] = Chess_piece.new(:knight, :white, [1, 0])
      expect(subject.check_king_condition([0, 0], subject.board, [[0, 1], [1, 0]])).to eql(:blocked)         
    end



  end
end