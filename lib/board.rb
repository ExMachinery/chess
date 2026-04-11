require_relative 'chess_piece'
class Board
  attr_accessor :state, :turn, :ui, :game, :halfmove, :fullmove, :number_of_pieces, :draw_type
  def initialize(ui, game)
    @ui = ui
    @game = game
    @state = Array.new(8) { Array.new(8, nil) }
    @turn = :white
    @halfmove = 0 # 100 means draw
    @fullmove = 1
    @number_of_pieces = 0
    @draw_type = nil
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
    @number_of_pieces = 32
  end

  def process_draw_condition
    counter = 0
    high_pieces = []
    @state.each do |row|
      row.each do |piece|
        if piece
          counter += 1
          high_pieces << piece.type if [:rook, :knight, :bishop, :queen].include?(piece.type)
        end
      end
    end
    if counter == @number_of_pieces
      @halfmove += 1
    else
      @number_of_pieces = counter
      @halfmove = 0
    end
    if @number_of_pieces <= 3
      @draw_type = :insufficient_material if high_pieces.include?(:bishop) || high_pieces.include?(:knight)
    end
  end

  def convert_board_to_fen
    state_str = []
    castling_is_possible = false
    castling_str = []
    en_passant_str = []
    @state.each do |row|
      counter = 0
      column = 0
      row.each do |piece|
        column += 1
        if piece
          state_str << counter.to_s if counter > 0
          counter = 0
          state_str << piece_to_fen(piece.type, piece.colour)
          
          if piece.castling
            castling_is_possible = true if piece.type == :king && piece.castling
            symbol = "k" if ([[0, 7], [7, 7]]).include?(piece.position)
            symbol = "q" if ([[0, 0], [7, 0]]).include?(piece.position)
            symbol = symbol.upcase if piece.colour == :white && symbol
            castling_str << symbol
          end
          en_passant_str << @ui.convert_notation(piece.position, :to_human) if piece.en_passant
        else
          counter += 1
          state_str << counter.to_s if column == 8
        end
      end
      state_str << "/"
    end
    state_str.pop
    state_str = [state_str.join("")]
    turn_str = @turn == :white ? ["w"] : ["b"]
    castling_str = [castling_str.join("")]
    castling_str = ["-"] if !castling_is_possible
    en_passant_str = ["-"] if en_passant_str.empty?
    halfmove_str = [@halfmove.to_s] 
    fullmove_str = [@fullmove.to_s] 

    final = state_str + turn_str + castling_str + en_passant_str + halfmove_str + fullmove_str
    final = final.join(" ")
    final
  end

  def convert_fen_to_board(instruction)
    fen_sections = instruction.split(" ")
    state = fen_sections[0].split("/")
    turn = fen_sections[1]
    castling = fen_sections[2]
    en_passant = fen_sections[3]
    @halfmove = fen_sections[4].to_i 
    @fullmove = fen_sections[5].to_i 

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
        else
          @number_of_pieces += 1
          properties = fen_notation(symb)
          type, colour = properties[0], properties[1]
          @state[row][column] = Chess_piece.new(type, colour, [row, column])
          
          piece = @state[row][column]
          piece.castling = false if piece.type == :rook || piece.type == :king
          @game.white_king = [row, column] if piece.type == :king && piece.colour == :white
          @game.black_king = [row, column] if piece.type == :king && piece.colour == :black
          column += 1
        end
      end
      row += 1
    end
  end


  def fen_notation(symbol)
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

  def piece_to_fen(type, colour)
    symbol = case type
    when :pawn then "p"
    when :rook then "r"
    when :knight then "n"
    when :bishop then "b"
    when :queen then "q"
    when :king then "k"
    end
    symbol = symbol.upcase if colour == :white
    symbol
  end

  def add_castling(castling)
    castling.split("").each do |castling_status|
      case castling_status
      when "k" then @state[0][7]&.castling = true
      when "q" then @state[0][0]&.castling = true
      when "K" then @state[7][7]&.castling = true
      when "Q" then @state[7][0]&.castling = true
      end      
    end
    @state[0][4]&.castling = true if castling.include?("k") || castling.include?("q")
    @state[7][4]&.castling = true if castling.include?("K") || castling.include?("Q")
  end

  def save_board
    board = convert_board_to_fen
    File.write("./save/save.yml", board)
  end

  def load_board
    return nil unless File.exist?("./save/save.yml")
    board_str = File.read("./save/save.yml")
    convert_fen_to_board(board_str)
  end
end


