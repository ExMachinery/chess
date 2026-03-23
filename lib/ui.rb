require_relative 'chess_piece'
require_relative 'board'

class UI
  def initialize
    
  
  end


  def render_board(board, moves = [])
    piece = nil
    counter = 8
    print "\n"
    board.each_with_index do |row, i|
      print "#{counter} "
      counter -= 1
      row.each_with_index do |val, j|
        if val
          case val.type
          when :pawn then val.colour == :white ? piece = "\u2659" : piece = "\u265F"
          when :king then val.colour == :white ? piece = "\u2654" : piece = "\u265A"
          when :queen then val.colour == :white ? piece = "\u2655" : piece = "\u265B"
          when :rook then val.colour == :white ? piece = "\u2656" : piece = "\u265C"
          when :bishop then val.colour == :white ? piece = "\u2657" : piece = "\u265D"
          when :knight then val.colour == :white ? piece = "\u2658" : piece = "\u265E"
          end
        else
          piece = " "
        end

        if i+j == 0
          if moves.include?([i, j])
            print "\e[48;2;255;127;0m #{piece} "
          else
            print "\e[48;2;240;217;181m #{piece} "
          end
          next
        end
        if moves.include?([i, j])
          print "\e[48;2;255;127;0m #{piece} "
        else
          print "\e[48;2;240;217;181m #{piece} " if (i+j).even?
          print "\e[0m #{piece} " if (i+j).odd?
        end
      end
      print "\e[0m"
      print "\n"
    end
    print "   A  B  C  D  E  F  G  H  "
    print "\n"
  end

  def convert_notation(coordinates, notation)
    digit_dictionary = ["8", "7", "6", "5", "4", "3", "2", "1"]
    leter_dictionary = ["a", "b", "c", "d", "e", "f", "g", "h"]
    result = nil

    # From digial to human
    if notation == :to_human
      x, y = coordinates[0], coordinates[1]
      result = "#{leter_dictionary[y]}#{digit_dictionary[x]}"
    end

    # From human to digital
    if notation == :to_machine
      array = coordinates.downcase.split("").reverse
      result = [digit_dictionary.index(array[0]), leter_dictionary.index(array[1])]
    end
    result
  end



  def print_piecelist(pieces, board)
    counter = 0
    pieces.each do |piece|
      x, y = piece[0], piece[1]
      coordinate = convert_notation(piece, :to_human)
      print "\e[48;2;169;169;169m  #{board[x][y].type.to_s.capitalize} #{coordinate.upcase}  "
      print "\e[0m  "
      counter += 1
      if counter == 8
        print "\n\n"
      end
    end
  end
end

test = Board.new
test.prepare_for_new_game
ui = UI.new
# ui.render_board(test.board, [[2, 0], [3, 0]])
# print "\e[48;2;255;127;0m #{piece} "
# puts ui.convert_notation([0, 0], :to_human)
# p ui.convert_notation("E4", :to_machine)
pieces = [[0,0], [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7]]
ui.print_piecelist(pieces, test.board)