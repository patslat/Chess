require 'pp'
require 'yaml'
require 'colorize'
require './chess.rb'
require './board.rb'
require './piece.rb'

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

class ComputerPlayer
  attr_reader :color
  def initialize(color)
    @color = color
  end

  def get_move
    move = [[get_rand, get_rand], [get_rand, get_rand]]
    move
  end

  def get_rand
    (0..7).to_a.sample
  end
end