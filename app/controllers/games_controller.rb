class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # POST
  def create
    player = Player.find_by(:name => params[:player_initials])
    puts "Player #{player}"
    unless player
      player = Player.create!(name: params[:player_initials])
    end

    puts "Player #{player.id}"

    @game = Game.new(
        user_id: player.id,
        player_move_count: 0,
        game_data: Game.default_game_data
    )

    puts "GAME CREATED #{@game}"

    if @game.save
      render json: @game, status: 201
    else
      render json: { errors: @game.errors }, status: 500
    end
  end

  # PATCH/PUT
  def player_move
    puts("PARAMS -- #{params}")
    player_move = params[:player_move]


    HandlePlayerMove.new(params[:id], player_move).execute

    @game = Game.find(params[:id])

    if @game
      render json: @game, status: 200
    else
      render json: { errors: @game.errors }, status: 500
    end
  end
end