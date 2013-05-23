require 'pp'
require 'yaml'
require 'colorize'
require './player.rb'
require './chess.rb'
require './piece.rb'

class Board
  def initialize
    @board = generate_board
    generate_pieces
  end

  def display_board
    white_pieces = {King => "\u{2654}", Queen => "\u{2655}",
                    Rook => "\u{2656}", Bishop => "\u{2657}",
                    Knight => "\u{2658}", Pawn => "\u{2659}"}
    black_pieces = {King => "\u{265A}", Queen => "\u{265B}",
                    Rook => "\u{265C}", Bishop => "\u{265D}",
                    Knight => "\u{265E}", Pawn => "\u{265F}"}


    board.each_with_index do |row, i|
      8.times { print "----------" }
      puts
      row.each_with_index do |col, i2|
        piece = board[i][i2]

        piece_name = "#{i}#{i2}"
        unless piece == nil
          color = piece.color
          if color == :white
            type = white_pieces[piece.class]
          else
            type = black_pieces[piece.class]
          end
          piece_name = "#{i}#{i2}#{type}".center(8).send(color)
        end

        print "| " + "#{piece_name.center(8)}".colorize( :light_white )
      end

      puts "|\n|\n|\n"
    end
    8.times { print "----------" }
    puts
  end

  def generate_board
    Array.new(8) { Array.new(8) }
  end

  def generate_pieces
    what_to_build = { 0 => Rook, 7 => Rook, 1 => Knight, 6 => Knight,
                      2 => Bishop, 5 => Bishop, 3 => Queen, 4 => King }

    8.times do |row_index|
      8.times do |col_index|
        if row_index == 0
          piece = what_to_build[col_index].new([row_index, col_index], :black)
        elsif row_index == 1
          piece = Pawn.new([row_index, col_index], :black)
        elsif row_index == 6
          piece = Pawn.new([row_index, col_index], :white)
        elsif row_index == 7
          piece = what_to_build[col_index].new([row_index, col_index], :white)
        else
          piece = nil
        end

        @board[row_index][col_index] = piece
      end
    end
  end

  def make_move(piece, destination)
    board[piece.row][piece.col] = nil
    dest_row, dest_col = destination
    piece.row, piece.col = dest_row, dest_col

    board[piece.row][piece.col] = piece
  end

  def get_piece(coordinate)
    row, col = coordinate
    board[row][col] unless row.nil? || col.nil?
  end

  def board
    @board
  end

  def clone
    YAML.load(self.to_yaml)
  end

  def color_occupied_by(coord)
    row, col = coord
    if @board[row][col]
      @board[row][col].color
    else
      nil
    end
  end

  def self.on_board?(coord)
    row, col = coord
    (0..7).include?(row) && (0..7).include?(col)
  end
end