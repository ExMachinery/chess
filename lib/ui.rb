require_relative 'chess_piece'
require_relative 'board'
require_relative 'player'

class UI
  def initialize
    
  end

  def get_new_players_name
    p1, p2 = nil, nil
    puts "White player, what is your nickname?"
    p1 = gets.chomp
    puts "Black player, what is your nickname?"
    p2 = gets.chomp
    return [p1, p2]
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
      if counter == 4
        print "\n\n"
        counter = 0
      end
    end
  end

  def get_pick(player, pieces, board)
    puts "#{player.name} (#{player.colour}), pick a chess piece. 'Exit' for abort game."
    pick = nil
    valid = false
    until valid
      input = gets.chomp.downcase
      if input == "exit"
        return nil
      elsif input.match?(/\A[a-h][1-8]\z/i)
        pick = convert_notation(input, :to_machine)
        if pieces.include?(pick)
          valid = true
          next
        end
        puts "You cant move those"
      else
        puts "Invalid pick. Try again! Use letter coordinate frist and digit coordinate second (like 'E2')"
      end
    end
    pick
  end

  def get_move(moves, board)
    move = nil
    puts "Choose where you want to move from orange squares. Type 'c' to Cancel."
    valid = false
    until valid
      input = gets.chomp.downcase
      if input == 'c'
        move = false
        valid = true
      elsif input.match?(/\A[a-h][1-8]\z/i)
        move_for_check = convert_notation(input, :to_machine)
        if moves.include?(move_for_check)
          move = move_for_check
          valid = true
        else
          puts "This can't be done. Try again."
        end
      end
    end
    move
  end

  def alert_piece_block(position, board)
    for_human_location = convert_notation(position, :to_human)
    x, y = position[1], position[2]
    puts "#{board[x][y].type.to_s.capitalize} on #{for_human_location} is blocked and have no moves. Try another one."
  end

  def clear
    system("clear")
  end
end

test = Board.new
test.prepare_for_new_game
ui = UI.new
ui.get_player_move("Billy", [[1, 0]], test.board)

