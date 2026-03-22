require_relative 'chess_piece'

class UI
  def initialize
    
  end


  def render_board(board)
    piece = nil
    print "\n"
    board.each_with_index do |row, i|
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
          print "\e[48;2;240;217;181m #{piece} "
          next
        end
        print "\e[48;2;240;217;181m #{piece} " if (i+j).even?
        print "\e[0m #{piece} " if (i+j).odd?
      end
      print "\e[0m"
      print "\n"
    end
    print "\n"
  end
end