require_relative 'chess_piece'
class Board
  attr_accessor :state, :turn, :ui, :game
  def initialize(ui, game)
    @ui = ui
    @game = game
    @state = Array.new(8) { Array.new(8, nil) }
    @turn = :white
  end

  def prepare_for_new_game
    8.times do |num|
      @state[1][num] = Chess_piece.new(:pawn, :black, [1, num])
      @state[6][num] = Chess_piece.new(:pawn, :white, [6, num])
    end
    
    2.times do |num|
      num == 0 ? side = 0 : side = 7
      num == 0 ? colour = :black : colour = :white
      @state[side][0] = Chess_piece.new(:rook, colour, [side, 0])
      @state[side][7] = Chess_piece.new(:rook, colour, [side, 7])
      @state[side][1] = Chess_piece.new(:knight, colour, [side, 1])
      @state[side][6] = Chess_piece.new(:knight, colour, [side, 6])
      @state[side][2] = Chess_piece.new(:bishop, colour, [side, 2])
      @state[side][5] = Chess_piece.new(:bishop, colour, [side, 5])
      @state[side][3] = Chess_piece.new(:queen, colour, [side, 3])
      @state[side][4] = Chess_piece.new(:king, colour, [side, 4])
    end
  end

  def convert_fen_to_board(instruction)
    fen_sections = instruction.split(" ")
    state = fen_sections[0].split("/")
    turn = fen_sections[1]
    castling = fen_sections[2]
    en_passant = fen_sections[3]
    halfmove = fen_sections[4] # Unused
    fullmove = fen_sections[5] # Unused

    convert_state_and_fill(state)
    @turn = :black if turn == "b"
    add_castling(castling)

    if en_passant != "-"
      en_passant = @ui.convert_notation(en_passant, :to_machine)
      @state[en_passant[0]][en_passant[1]]&.en_passant = true
    end
  end

  def convert_state_and_fill(state) 
    row = 0
    state.each do |line|
      column = 0
      symbols = line.split("")
      symbols.each do |symb|        
        if symb.to_i != 0
          symb.to_i.times {column += 1}
          p column
        else
          properties = fel_notation(symb)
          type, colour = properties[0], properties[1]
          @state[row][column] = Chess_piece.new(type, colour, [row, column])
          
          piece = @state[row][column]
          piece.castling = false if piece.type == :rook || piece.type == :king
          @game.white_king = [row, column] if piece.type == :king && piece.colour == :white
          @game.black_king = [row, column] if piece.type == :king && piece.colour == :black
          column +=1
        end
      end
      row += 1
    end
  end


  def fel_notation(symbol)
    colour = symbol.downcase == symbol ? :black : :white
    type = case symbol.downcase
    when "p" then :pawn
    when "r" then :rook
    when "n" then :knight
    when "b" then :bishop
    when "q" then :queen
    when "k" then :king
    end
    return [type, colour]
  end

  def add_castling(castling)
    castling.split("").each do |castling_status|
      case castling_status
      when "k" then @board[0][7]&.castling = true
      when "q" then @board[0][0]&.castling = true
      when "K" then @board[7][7]&.castling = true
      when "Q" then @board[7][0]&.castling = true
      end      
    end
    @board[0][4]&.castling = true if castling.include?("k") || castling.include?("q")
    @board[7][4]&.castling = true if castling.include?("K") || castling.include?("Q")
  end
end


