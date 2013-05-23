require 'pp'
require 'yaml'
require 'colorize'
require './player.rb'
require './board.rb'
require './piece.rb'

class Chess
  def initialize(white_player, black_player)
    @board = Board.new
    @white = white_player
    @black = black_player
    @turn = @white
  end

  def play
    until Piece.checkmate?(@turn.color, @board.clone)
      @board.display_board

      prompt_for_move

      piece_location, destination = @turn.get_move

      piece = @board.get_piece(piece_location)
      if !valid_move?(piece, destination)
        prompt_invalid_move
        next
      end

      @board.make_move(piece, destination)
      swap_turn
    end

    winner
  end

  def swap_turn
    @turn = @turn.color == :white ? @black : @white
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
    puts "#{@turn.color.capitalize}, enter coordinates of piece to move and destination:"
  end

  def prompt_invalid_move
    puts "Invalid move, please enter another."
  end

  def winner
    puts "#{Chess.opposite_color(@turn.color).to_s.capitalize} Wins!"
  end
end

if __FILE__ == $PROGRAM_NAME
  player_1 = Player.new(:white)
  player_2 = ComputerPlayer.new(:black)
  chess = Chess.new(player_1, player_2)
  chess.play
end