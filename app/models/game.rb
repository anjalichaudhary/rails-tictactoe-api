class Game < ApplicationRecord

  def self.default_game_data

    @game_board = {}
    (1..9).each {|x| @game_board[x] = x}
    @game_board
  end

  # def self.find_player_won_games
  #   self.where(player_won: true)
  # end


  def make_player_move!(player_move_position)
    self.game_data[player_move_position] = "O"
    self.player_move_count += 1
    self.save!
  end

  def make_computer_move!(computer_move_position)
    self.game_data[computer_move_position] = "X"
    self.save!
  end

  def player_won!
    self.update!(player_won: true, is_drawn: false, completed_at: Time.now)
  end

  def computer_won!
    self.update!(player_won: false, is_drawn: false, completed_at: Time.now)
  end

  def is_drawn!
    self.update!(is_drawn: true, completed_at: Time.now) if player_won == nil
  end

  def is_complete?
    self.player_won != nil || self.is_drawn != nil
  end

  def completed_time
    return unless self.completed_at
      seconds_to_complete = self.completed_at - self.created_at

    Time.at(seconds_to_complete).utc.strftime("%M:%S.%L")
  end
end

class CheckBoard

  attr_reader :game, :game_board

  def initialize(game_id)
    @game = Game.find(game_id)
    puts("[initialize] #{@game.game_data}")
    @game_board = game.game_data
    @winning_combinations = [ [1,2,3],
                              [4,5,6],
                              [7,8,9],
                              [1,4,7],
                              [2,5,8],
                              [3,6,9],
                              [1,5,9],
                              [3,5,7] ]

  end

  def execute
    puts "@game_board in execute of Check board #{@game_board}"

    @winning_combinations.each do |array|
      puts "ARRAY #{array}"
     if @game_board[array[0]] == "X" && @game_board[array[1]] == "X" && @game_board[array[2]] == "X"
       puts "Computer Won"
       return game.computer_won!
     elsif @game_board[array[0]] == "O" && @game_board[array[1]] == "O" && @game_board[array[2]] == "O"
       puts "Player Won"
       return game.player_won!
     elsif (@game_board.select {|k,v| v = v.is_a?(Integer) }.keys).length == 0
        puts "Game drawn"
        return game.is_drawn!
     end
    end
    nil
  end

end

class HandlePlayerMove

  attr_reader :game, :game_board, :player_move_position

  def initialize(game_id, player_move)
    @game = Game.find(game_id)
    @game_board = game.game_data
    @player_move_position = player_move
  end

  def execute
    val = record_player_move
    puts("val #{val}")
    check_game_board
    @game.reload
    if val
      unless game.is_complete?
        record_computer_move
        check_game_board
      end
    end
  end


  private

  def record_player_move
    if @game_board[player_move_position] != 'X' && @game_board[player_move_position] != 'O'
      game.make_player_move!(player_move_position)
      true
    else
      false
    end
  end

  def check_game_board
    CheckBoard.new(game.id).execute
  end

  def record_computer_move
    HandleComputerMove.new(game.id).execute
  end

end

class HandleComputerMove

  attr_reader :game, :game_board

  def initialize(game_id)
    @game = Game.find(game_id)
    @game_board = game.game_data
  end

  def execute
    record_computer_move
  end


  private

  def empty_positions
    # return the array indexes for which the value is an integer
    # indicating the position is not chosen by anyone yet
    @game_board.select {|k,v| v = v.is_a?(Integer) }.keys
  end

  def record_computer_move
    if empty_positions.length > 0
      position = empty_positions.sample
      game.make_computer_move!(position)
    else
      @game.is_drawn!
    end
  end

end