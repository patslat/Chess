require 'pp'
require 'yaml'

class Chess
  def initialize(white, black)
    @board = Board.new
    @white = white
    @black = black

    @turn = @white
  end

  def play
    while valid_moves?

      piece, destination = @turn.get_move until valid_move?(piece, destination)

    end
  end

  def valid_moves?
    #check if any valid moves possible, else game over
  end

  def valid_move?(piece, destination)
    return false if @board.piece.color != @turn.color
    @board.piece.valid_move?(destination, @board.board) && !puts_king_in_check?
  end

  def self.opposite_color(color)
    color == :white ? :black : :white
  end
end


class Board
  def initialize
    # magic
    @board = generate_board
  end

  def display_board
    board.each_with_index do |row, i| 
      row.each_with_index do |col, i2|
        piece = board[i][i2]
        
        piece_name = ""
        unless piece == nil
          color = piece.color.to_s[0]
          type = piece.class.to_s
          piece_name = "#{color} #{type}"
        end
        
        print %Q"| #{piece_name.center(10)}"
      end
      
      puts "|\n\n\n|"
    end
  end



  def generate_board
    Array.new(8) { Array.new(8) }
  end

  def generate_pieces
    what_to_build = { 0 => Rook, 7 => Rook, 1 => Knight, 6 => Knight,
                      2 => Bishop, 5 => Bishop, 3 => King, 4 => Queen }

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
  def initialize(color)
    @color = color
  end

  def get_move

    #returns piece location and destination coordinates
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

  def self.is_in_check?(color, clone_board)
    king_location = []

    bad_guy_color = Chess.opposite_color(color)
    bad_guys = []

    clone_board.board.each_with_index do |row, rindex|
      row.each_with_index do |col, cindex|
        next if col == nil
        bad_guys << col if col.color == bad_guy_color
        king_location = [rindex, cindex] if col.class == King && col.color == color
      end
    end


    bad_guys.any? do |piece|
      piece.valid_moves(clone_board).include?(king_location)
    end

  end


  def valid_move?(destination, board)
    valid_moves(board).include?(destination)
    #check?(make_fake_move(board, destination))
  end

  def valid_moves(enum, board) #works for long distance movers
    valid_moves = []
    piece = self.class.to_sym
    piece = get_pawn_color if piece == :pawn

    DELTAS[piece].each do |delta_row, delta_col|
      enum.each do |n|
        new_coord = [row + (n * delta_row), col + (n * delta_col)]
        break if !Board.on_board?(new_coord)

        case board.color_occupied_by(new_coord)
        when nil
          valid_moves << new_coord
        when Chess.opposite_color(color)
          valid_moves << new_coord unless is_a? Pawn
          break
        else
          break
        end
      end

    end
    valid_moves
  end
end

class Rook < Piece
  def initialize(location, color)
    super(location, color)
  end

  def self.to_sym
    :rook
  end
 
  def valid_moves(board)
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

  def valid_moves(board)
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

  def valid_moves(board)
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

  def valid_moves(board)
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

  def valid_moves(board)
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

  def valid_moves(board)
    if [row, col] == @start_location
      valid_moves = super((1..2), board)
    else
      valid_moves = super((1..1), board)
    end

    if color == :black
      eat_left, eat_right = [row + 1, col - 1], [row + 1, col + 1]
    else
      eat_left, eat_right = [row - 1, col - 1], [row - 1, col + 1]
    end

    op_color = Chess.opposite_color(color)
    valid_moves << eat_left if board.color_occupied_by(eat_left) == op_color
    valid_moves << eat_right if board.color_occupied_by(eat_right) == op_color
    valid_moves
  end
end

if __FILE__ == $PROGRAM_NAME
  b = Board.new

  b.generate_board
  b.generate_pieces
  # pp b


  dup_board = b.clone
  # dup_board.board[6][3] = Queen.new([6,3], :black)
  # p Piece.is_in_check?(:white, dup_board)
  b.display_board

  # rook = Rook.new([5, 5], :white)
  # p "rook valid moves: #{rook.valid_moves(b)}"
  # p rook.valid_move?([1,5], b)
  
  
  # bish = Bishop.new([6, 6], :white)
  # p "bishop valid moves: #{bish.valid_moves(b)}"
  
  # queen = Queen.new([3, 3], :black)
  # p queen.valid_moves(b)

  # king = King.new([1, 3], :black)
  # p king.valid_moves(b)

  
  # pawn = Pawn.new([2, 4], :white)
  # pawn.color
  # p pawn.valid_moves(b)

end