require 'pp'
require 'yaml'
require 'colorize'

class Chess
  def initialize(white_player, black_player)
    @board = Board.new
    @white = white_player
    @black = black_player

    @turn = @white
  end

  def play
    until p Piece.checkmate?(@turn.color, @board.clone)
      @board.display_board

      prompt_for_move

      piece_location, destination = @turn.get_move

      piece = @board.get_piece(piece_location)
      next if !valid_move?(piece, destination)


      @board.make_move(piece, destination)
      swap_turn
    end
  end

  def swap_turn
    @turn = @turn.color == :white ? @black : @white
  end

  def possible_moves?
    #check if any valid moves possible, else game over
  end

  def valid_move?(piece, destination)
    piece &&
    piece_belongs_to_player?(piece) &&
    piece.valid_move?(destination, @board.clone)
  end

  def self.opposite_color(color)
    color == :white ? :black : :white
  end

  def piece_belongs_to_player?(piece)
    piece.color == @turn.color
  end

  def prompt_for_move
    puts "#{@turn.color.capitalize}, enter coordinates of piece to move and destination: "
  end

end


class Board
  def initialize
    # magic
    @board = generate_board
    generate_pieces
  end

  def display_board
    white_pieces = {King => "\u{2654}", Queen => "\u{2655}", Rook => "\u{2656}", Bishop => "\u{2657}", Knight => "\u{2658}", Pawn => "\u{2659}"}
    black_pieces = {King => "\u{265A}", Queen => "\u{265B}", Rook => "\u{265C}", Bishop => "\u{265D}", Knight => "\u{265E}", Pawn => "\u{265F}"}


    board.each_with_index do |row, i|
      8.times { print "----------" }
      puts
      row.each_with_index do |col, i2|
        #background_color = {:background => set_background_color(i, i2)}
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

  # def set_background_color(row, col)
#     if row.even?
#       return :brown if col.odd?
#       return :gray
#     else
#       return :brown if col.odd?
#       return :gray
#     end
#   end


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
    row, loc = coordinate
    board[row][loc]
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
class Player
  attr_reader :color
  def initialize(color)
    @color = color
  end

  def get_move
    piece_row, piece_col, dest_row, dest_col = gets.chomp.scan(/\d/).map(&:to_i)
    [[piece_row, piece_col], [dest_row, dest_col]]
  end


end


class Piece
  DELTAS = {
            :rook => [[1, 0], [-1, 0], [0, 1], [0, -1]],
            :queen => [[1, 0], [-1, 0], [0, 1], [0, -1],
                      [1, 1], [-1, -1], [-1, 1], [1, -1]],
            :bishop => [[1, -1], [-1, 1], [1, 1], [-1, -1]],
            :king => [[1, 0], [-1, 0], [0, 1], [0, -1],
                      [1, 1], [-1, -1], [-1, 1], [1, -1]],
            :knight => [[2, 1], [1, 2], [-2, -1], [-1, -2],
                        [-2, 1], [-1, 2], [1, -2], [2, -1]],
            :blackpawn => [[1, 0]],
            :whitepawn => [[-1, 0]]
           }

  attr_accessor :row, :col, :color, :location
  def initialize(location, color)
    @row, @col = location
    @color = color

  end

  def self.checkmate?(color, board)
    pieces = Piece.get_all_pieces(color, board)
    pieces.none? do |piece|
      p piece
      piece.possible_moves(board).any? do |move|
        p "CHECKING POSSIBLE MOVES FOR #{piece}, #{move}"
        p piece.valid_move?(move, board)
      end
    end
  end

  def self.get_all_pieces(color, board)
    colors_pieces = []
    8.times do |row|
      8.times do |col|
        piece = board.get_piece([row, col])
        next if piece.nil? || piece.color == Chess.opposite_color(color)
        colors_pieces << piece
      end
    end
    colors_pieces
  end

  def self.is_king_in_check?(king_color, clone_board)
    king_location = []

    bad_guy_color = Chess.opposite_color(king_color)
    bad_guys = []

    clone_board.board.each_with_index do |row, rindex|
      row.each_with_index do |piece, cindex|
        next if piece == nil
        piece_color = piece.color
        bad_guys << piece if piece_color == bad_guy_color

        if piece.class == King && piece_color == king_color
          king_location = [rindex, cindex]
        end
      end
    end

    bad_guys.any? do |piece|
      piece.possible_moves(clone_board).include?(king_location)
    end

  end


  def valid_move?(destination, clone_board)
    possible_moves(clone_board).include?(destination) &&
    # king is not in check if you make requested move
    !Piece.is_king_in_check?(color, make_fake_move(clone_board, destination))
  end

  def make_fake_move(clone_board, destination)
    dest_row, dest_col = destination

    clone_board.board[row][col] = nil
    clone_board.board[dest_row][dest_col] = self
    clone_board

  end

  def possible_moves(enum, board) #works for long distance movers
    possible_moves = []
    piece = self.class.to_sym
    piece = get_pawn_color if piece == :pawn

    DELTAS[piece].each do |delta_row, delta_col|
      enum.each do |n|
        new_coord = [row + (n * delta_row), col + (n * delta_col)]
        break if !Board.on_board?(new_coord)



        case board.color_occupied_by(new_coord)
        when nil
          possible_moves << new_coord
        when Chess.opposite_color(color)
          possible_moves << new_coord unless is_a? Pawn
          break
        else
          break
        end
      end

    end
    possible_moves
  end
end

class Rook < Piece
  def initialize(location, color)
    super(location, color)
  end

  def self.to_sym
    :rook
  end

  def possible_moves(board)
    super((1..7), board)
  end
end

class Queen < Piece
  def initialize(location, color)
    super(location, color)
  end

  def self.to_sym
    :queen
  end

  def possible_moves(board)
    super((1..7), board)
  end
end

class Bishop < Piece
  def initialize(location, color)
    super(location, color)
  end

  def self.to_sym
    :bishop
  end

  def possible_moves(board)
    super((1..7), board)
  end
end

class King < Piece
  def initalize(location, color)
    super(location, color)
  end

  def self.to_sym
    :king
  end

  def possible_moves(board)
    super((1..1), board)
  end
end

class Knight < Piece
  def initalize(location, color)
    super(location, color)
  end

  def self.to_sym
    :knight
  end

  def possible_moves(board)
    super((1..1), board)
  end
end

class Pawn < Piece
  def initialize(location, color)
    super(location, color)
    @start_location = location
  end

  def self.to_sym
    :pawn
  end

  def get_pawn_color
    color == :black ? :blackpawn : :whitepawn
  end

  def possible_moves(board)
    if [row, col] == @start_location
      possible_moves = super((1..2), board)
    else
      possible_moves = super((1..1), board)
    end

    if color == :black
      eat_left, eat_right = [row + 1, col - 1], [row + 1, col + 1]
    else
      eat_left, eat_right = [row - 1, col - 1], [row - 1, col + 1]
    end

    op_color = Chess.opposite_color(color)
    possible_moves << eat_left if board.color_occupied_by(eat_left) == op_color
    possible_moves << eat_right if board.color_occupied_by(eat_right) == op_color
    possible_moves
  end
end

if __FILE__ == $PROGRAM_NAME
  # b = Board.new
  #
  # b.generate_board
  # b.generate_pieces
  # pp b

  #
  # dup_board = b.clone
  # dup_board.board[6][3] = Queen.new([6,3], :black)
  # p Piece.is_in_check?(:white, dup_board)
  # b.display_board

  # rook = Rook.new([5, 5], :white)
  # p "rook valid moves: #{rook.possible_moves(b)}"
  # dup_board.board[5][5] = rook
  # dup_board.display_board
  # p rook.valid_move?([1,5], dup_board)

  #
  # bish = Bishop.new([6, 6], :white)
  # p "bishop valid moves: #{bish.possible_moves(b)}"
  #
  # queen = Queen.new([3, 3], :black)
  # p queen.possible_moves(b)
  #
  # king = King.new([1, 3], :black)
  # p king.possible_moves(b)
  #
  #
  # pawn = Pawn.new([2, 4], :white)
  # pawn.color
  # p pawn.possible_moves(b)

  player_1 = Player.new(:white)
  player_2 = Player.new(:black)
  chess = Chess.new(player_1, player_2)
  chess.play

end
