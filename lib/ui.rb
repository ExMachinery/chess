require_relative 'chess_piece'
require_relative 'board'
require_relative 'player'

class UI
  def initialize
    # IM THE MIGHTY UI! I DONT NEED ANY INSTANCE VARIABLES!
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
          when :pawn then piece = val.colour == :white ? "\e[38;2;255;255;255m\u265F" : "\e[38;2;102;102;235m\u265F"
          when :king then piece = val.colour == :white ? "\e[38;2;255;255;255m\u265A" : "\e[38;2;102;102;235m\u265A"
          when :queen then piece = val.colour == :white ? "\e[38;2;255;255;255m\u265B" : "\e[38;2;102;102;235m\u265B"
          when :rook then piece = val.colour == :white ? "\e[38;2;255;255;255m\u265C" : "\e[38;2;102;102;235m\u265C"
          when :bishop then piece = val.colour == :white ? "\e[38;2;255;255;255m\u265D" : "\e[38;2;102;102;235m\u265D"
          when :knight then piece = val.colour == :white ? "\e[38;2;255;255;255m\u265E" : "\e[38;2;102;102;235m\u265E"
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

    # From digital to human
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
    print "\n"
  end

  def get_pick(player, pieces, board)
    puts "#{player.name} (#{player.colour}), pick a chess piece. 'Exit' for abort game."
    pick = nil
    valid = false
    until valid
      input = gets.chomp.downcase
      if input == "exit"
        return :exit
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

  def get_player_move(moves, board)
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
    x, y = position[0], position[1]
    puts "#{board[x][y].type.to_s.capitalize} on #{for_human_location} is blocked and have no moves. Try another one."
  end

  def choose_piece
    result = nil
    puts "Choose your new figure, which will replase your pawn."
    print "\n"
    print "\e[48;2;169;169;169m  1. QUEEN  "
    print "\e[0m  "
    print "\e[48;2;169;169;169m  2. ROOK  "
    print "\e[0m  "
    print "\e[48;2;169;169;169m  3. KNIGHT  "
    print "\e[0m  "
    print "\e[48;2;169;169;169m  4. BISHOP  "
    print "\e[0m  "
    print "\n"
    until result
      input = gets.chomp
      case input.to_i
      when 1 then result = :queen
      when 2 then result = :rook
      when 3 then result = :knight
      when 4 then result = :bishop
      else
        puts "Invalid input. Please, try again."
      end
    end
    result
  end

  # This alert should triggers when player trying to move piece which protect king from attack (preventing instant loose)
  def alert_king_is_vulnerable
    puts "Invalid move. King is exposed to attack."
  end

  def alert_check
    print "\e[48;2;255;127;0m  KING IS UNDER ATTACK!!!  "
    print "\e[0m  "
    print "\n\n"
  end

  def player_game_load?
    puts "There is an unfinished game. Do you like to continue (1) or start a new game (2)?"
    valid = false
    until valid
      input = gets.chomp
      case input.to_i
      when 1 then valid = 1
      when 2 then valid = 2
      else
        puts "Invalid input. 1 - for load saved game, 2 - for new game."
      end
    end
    valid == 1 ? true : false
  end

  def declare_tie(type)
    result = case type
    when :stalemate then "Stalemate. Draw!"
    when :draw_by_halfmove_rule then "Draw by halfmove rule!"
    when :insufficient_material then "Draw! Checkmate is impossible."
    end
    puts "#{result}"
  end

  def declare_win(winner)
    puts "Checkmate. #{winner.to_s} is won!"
  end

  def goodbye
    puts "Game saved! Have a nice day!"
  end

  def clear
    system("clear")
  end
end