Rails.application.routes.draw do

  post '/create' => 'games#create'
  patch '/player_move' => 'games#player_move'

end
