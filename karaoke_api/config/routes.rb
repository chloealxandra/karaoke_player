Rails.application.routes.draw do
  resources :queue
  # resque_web_constraint = lambda { |request| request.remote_ip == '127.0.0.1' }
  # constraints resque_web_constraint do
  #   mount Resque::Server, :at => "/resque"
  # end
  resources :song_queue
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/new_karaoke_session' => 'kjams#new_karaoke_session'
  post '/play_pause' => 'kjams#play_pause'
  post 'singers' => 'kjams#singers'
  post '/search' => 'kjams#search'
  post '/login' => 'kjams#login'
  post '/logout' => 'kjams#logout'
  post '/enqueue' => 'kjams#enqueue'
  post '/get_all_songs' => 'kjams#get_all_songs'
  post '/get_queue' => 'kjams#get_queue'
  post '/play_status' => 'kjams#play_status'
  post '/skip' => 'kjams#skip'
  post '/pitch_up' => 'kjams#pitch_up'
  post '/pitch_down' => 'kjams#pitch_down'
  post '/new_singer' => 'kjams#new_singer'
  post '/move_song' => 'kjams#move_song'
  post '/remove_current_song' => 'kjams#remove_current_song'
  post '/get_singers' => 'kjams#get_singers'

end
