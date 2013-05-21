require 'pp'
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
    @board.piece.valid_move?(destination) && !puts_king_in_check?
  end

  def self.opposite_color(color)
    color == :white ? :black : :white
  end
end


class Board
  attr_accessor :board
  def initialize
    # magic
    @board = generate_board
  end

  def generate_board
    Array.new(8) { Array.new(8) }
  end

  def generate_pieces
    8.times do |row_index|
      8.times do |col_index|

        if row_index < 2
          piece = Piece.new(self, [row_index, col_index], :black)
        elsif row_index > 5
          piece = Piece.new(self, [row_index, col_index], :white)
        else
          piece = nil
        end
        # if row_index == 5 && col_index == 5 DELETE THIS TEST
        #   p "IN THE IF STATEMENT BUILDING ROOK"
        #   piece = Rook.new(self, [row_index, col_index], :white)
        # end
        board[row_index][col_index] = piece
      end
    end

  end

  def color_occupied_by(coord)
    row, col = coord
    if @board[row][col]
      @board[row][col].color
    else
      nil
    end
  end

  def on_board?(coord)
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
  def initialize(board, location, color)
    @board = board
    @row, @col = location
    @color = color

  end


  def valid_move?(destination)
    get_valid_moves.include?(destination)
  end

  def get_valid_moves(enum) #works for long distance movers
    valid_moves = []
    piece = self.class.to_sym
    piece = get_pawn_color if piece == :pawn

    DELTAS[piece].each do |delta_row, delta_col|
      enum.each do |n|
        new_coord = [row + (n * delta_row), col + (n * delta_col)]
        break if !@board.on_board?(new_coord)

        case @board.color_occupied_by(new_coord)
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
  def initialize(board, location, color)
    super(board, location, color)
  end
  def self.to_sym
    :rook
  end
  def get_valid_moves
    super((1..7))
  end
end

class Queen < Piece
  def initialize(board, location, color)
    super(board, location, color)
  end
  def self.to_sym
    :queen
  end
  def get_valid_moves
    super((1..7))
  end
end

class Bishop < Piece
  def initialize(board, location, color)
    super(board, location, color)
  end
  def self.to_sym
    :bishop
  end
  def get_valid_moves
    super((1..7))
  end
end

class King < Piece
  def initalize(board, location, color)
    super(board, location, color)
  end
  def self.to_sym
    :king
  end
  def get_valid_moves
    super((1..1))
  end
end

class Knight < Piece
  def initalize(board, location, color)
    super(board, location, color)
  end
  def self.to_sym
    :knight
  end
  def get_valid_moves
    super((1..1))
  end
end

class Pawn < Piece
  def initialize(board, location, color)
    super(board, location, color)
    @start_location = location
  end

  def self.to_sym
    :pawn
  end

  def get_pawn_color
    color == :black ? :blackpawn : :whitepawn
  end

  def get_valid_moves
    if [row, col] == @start_location
      valid_moves = super((1..2))
    else
      valid_moves = super((1..1))
    end

    if color == :black
      eat_left, eat_right = [row + 1, col - 1], [row + 1, col + 1]
    else
      eat_left, eat_right = [row - 1, col - 1], [row - 1, col + 1]
    end

    op_color = Chess.opposite_color(color)
    p op_color
    valid_moves << eat_left if @board.color_occupied_by(eat_left) == op_color
    valid_moves << eat_right if @board.color_occupied_by(eat_right) == op_color
    valid_moves
  end
end

if __FILE__ == $PROGRAM_NAME
  b = Board.new

  b.generate_board
  b.generate_pieces

  # rook = Rook.new(b, [5, 5], :white)
  #
  # p rook.get_valid_moves
  # p rook.valid_move?([1,5])
  #
  #
  # bish = Bishop.new(b, [6, 6], :white)
  # p bish.get_valid_moves
  #
  # queen = Queen.new(b, [3, 3], :black)
  # p queen.get_valid_moves

  # king = King.new(b, [1, 3], :black)
#   p king.get_valid_moves
p b

  pawn = Pawn.new(b, [2, 4], :white)
  pawn.color
  p pawn.get_valid_moves

end