require 'pp'
require 'yaml'
require 'colorize'
require './player.rb'
require './board.rb'
require './chess.rb'

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

  def self.find_king(color, board)
    8.times do |row|
      8.times do |col|
        piece = board.get_piece([row, col])
        next if piece.nil?
        return piece if piece.color == color && piece.class == King
      end
    end
  end

  def self.checkmate?(color, board)
    pieces = Piece.get_all_pieces(color, board)
    pieces.none? do |piece|
      piece.possible_moves(board).any? do |move|
        piece.valid_move?(move, board)
      end
    end
  end

  def self.is_king_in_check?(king_color, clone_board)
    king = Piece.find_king(king_color, clone_board)
    king_loc = [king.row, king.col]

    bad_guy_color = Chess.opposite_color(king_color)
    bad_guys = Piece.get_all_pieces(bad_guy_color, clone_board)

    bad_guys.any? do |piece|
      possible_moves = piece.possible_moves(clone_board)
      possible_moves.include?(king_loc)
    end
  end


  def valid_move?(dest, clone_board)
    possible_moves(clone_board).include?(dest) &&
    !Piece.is_king_in_check?(color, make_fake_move(clone_board.clone, dest))
  end

  def make_fake_move(clone_board, destination)
    dest_row, dest_col = destination

    duped_piece = clone_board.get_piece([row, col])
    duped_piece.row = dest_row
    duped_piece.col = dest_col

    clone_board.board[row][col] = nil
    clone_board.board[dest_row][dest_col] = duped_piece
    clone_board
  end

  def possible_moves(enum, board)
    possible_moves = []
    piece = self.class.to_sym
    piece = get_pawn_color if piece == :pawn

    DELTAS[piece].each do |delta_row, delta_col|
      enum.each do |n|
        new_coord = [row + (n * delta_row), col + (n * delta_col)]
        break if !Board.on_board?(new_coord)
        piece_in_target = board.get_piece(new_coord)
        if piece_in_target.nil?
          possible_moves << new_coord
        elsif piece_in_target.color == Chess.opposite_color(self.color)
          unless piece == :whitepawn || piece == :blackpawn
            possible_moves << new_coord
          end
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
      left_diag, right_diag = [row + 1, col - 1], [row + 1, col + 1]
    else
      left_diag, right_diag = [row - 1, col - 1], [row - 1, col + 1]
    end

    op_color = Chess.opposite_color(color)
    if board.color_occupied_by(left_diag) == op_color
      possible_moves << left_diag
    end
    if board.color_occupied_by(right_diag) == op_color
      possible_moves << right_diag
    end

    possible_moves
  end
end