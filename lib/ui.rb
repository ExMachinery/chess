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
end

test = Board.new
test.prepare_for_new_game
ui = UI.new
ui.render_board(test.board, [[2, 0], [3, 0]])
# print "\e[48;2;255;127;0m #{piece} "