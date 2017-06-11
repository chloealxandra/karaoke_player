class KjamsController < ApplicationController
  before_action :restrict_access

  @@room_ips = ["not using index 0", "http://localhost/"] #throw in -1 instead so index is proper

  #POST '/new_karaoke_session'

  #CWS_Path_NEW_SINGER: requires as params: kPostData_SUBMIT (empty string), kPostData_SINGER_NAME, kPostData_PASSWORD, and kPostData_PASSWORD_CONFIRM, it will then create a new singer, or return an error: that the singer name already exists, that no password was specified, or that the passwords don't match, then send the user to the singer's login screen.

  def new_singer #needs singer and room as params
    room_url = @@room_ips[params[:room].to_i]
    singer = get_singer
    if singer == ""
      Rails.logger.debug "creating a new singer!!!"
      response = HTTParty.post("#{room_url}newsinger", body: {singername: params[:singer], password: params[:singer], confirm: params[:singer], submit: 'Jam Out!'}) #it seems that the jam out thing is actually needed.
      Rails.logger.debug "got back #{response.body}"
      if response.code != 200
        Rails.logger.debug "something is wrong with the API request!!!!!!"
      else
        singer = get_singer
      end
    end
    return singer
  end


  #POST '/login'
  def login(singer_name = nil) #needs room and singer as params
    singer_to_find = singer_name || params[:singer]
    #TODO - validate login!
    room_url = @@room_ips[params[:room].to_i]
    singer = get_singer(singer_to_find)
    if singer == ""
      singer = new_singer
    else
      response = HTTParty.post("#{room_url}main", body: {singer: singer[:siID], password: singer[:name], submit: "Login"})
    end
  end

  #POST '/enqueue'
  def enqueue #needs room, singer and song as params
    room_url = @@room_ips[params[:room].to_i]
    login
    #TODO: validate login!
    singer = get_singer
    response = HTTParty.post("#{room_url}drop", body: {playlist: singer[:siID], song: params[:song]})
    render xml: response
    current_play_status = play_status
    if current_play_status.parsed_response == '0.0000' #indicates a stopped transport. pause would return '2.0000' and play '1.0000'
      play_pause
    end
  end

  #POST '/play_pause'
  #TODO - write seperate play and pause methods that check current status of room
  def play_pause #needs room as param
    room_url = @@room_ips[params[:room].to_i]
    Rails.logger.debug "about to hit play/pause!"
    HTTParty.post("#{room_url}command", query: {cmd_id: 1})
  end

  def play_status #needs room as param
    room_url = @@room_ips[params[:room].to_i]
    HTTParty.post("#{room_url}command", query: {cmd_id: 47})
  end

  def skip #needs room as param
    room_url = @@room_ips[params[:room].to_i]
    HTTParty.post("#{room_url}command", query: {cmd_id: 4})
    # current_play_status = play_status
    # if current_play_status.parsed_response == '0.0000' #indicates a stopped transport. pause would return '2.0000' and play '1.0000'
    #   play_pause
    # end
  end

  def pitch_up #needs room as param
    room_url = @@room_ips[params[:room].to_i]
    HTTParty.post("#{room_url}command", query: {cmd_id: 8})
  end

  def pitch_down #needs room as param
    room_url = @@room_ips[params[:room].to_i]
    HTTParty.post("#{room_url}command", query: {cmd_id: 9})
  end

  #POST '/search'
  def search #needs room and search string as params (search = \* returns all songs)
    room_url = @@room_ips[params[:room].to_i]
    response = Nokogiri::PList(HTTParty.post("#{room_url}search", body: {search: params[:search]}))
    render json: response["Playlists"][0]["Playlist Items"]
  end

  #POST '/get_all_songs'
  def get_all_songs
    room_url = @@room_ips[1]
    response = Nokogiri::PList(HTTParty.post("#{room_url}search", body: {search: '\*' }))
    render json: response["Playlists"][0]["Playlist Items"]
  end

  #POST '/remove_current_song'
  def remove_current_song
    room_url = @@room_ips[params[:room].to_i]
    response = Nokogiri::PList(HTTParty.post("#{room_url}rotation?"))
    singer_name = response["Playlists"][0]["Playlist Items"][0]["SNGR"]
    singer = get_singer(singer_name)
    response = HTTParty.post("#{room_url}main", body: {singer: singer[:siID]-1, password: singer[:name], submit: "Login"}) #it seems like siID is sometimes 0 indexed and sometimes 1 indexed!?!?
    cookie = response.headers['Set-Cookie']

    #get the plID for the tonight playlist of the user on top of queue using their cookie
    response = Nokogiri::PList(HTTParty.get("#{room_url}playlists", headers: {'Cookie' => cookie}))
    tonight_id = ""
    response["Playlists"][0]["Playlist Items"].each do |e| 
      if e["Name"] == "Tonight"
        tonight_id = e["Playlist ID"].to_i
      end
    end

    #get the piIx for the top song from the users tonight playlist using their cookie (Maybe this is always 1 or 0?)
    response = Nokogiri::PList(HTTParty.post("#{room_url}songs", {body: {playlist:  tonight_id}, headers: {cookie: cookie}}))
    piIx = response["Playlists"][0]["Playlist Items"][0]["piIx"].to_i
    
    skip #cause you can't remove the playing song
    #and finally remove it
    res = HTTParty.post("#{room_url}remove", {body: {playlist:  tonight_id, piIx: piIx}, headers: {cookie: cookie}})
    render xml: res
  end


  #POST '/logout'
  def logout #needs room as param
    room_url = @@room_ips[params[:room].to_i]
    response = HTTParty.post("#{room_url}logout")
    render xml: response.body
  end

  def get_queue #needs room and singer
    room_url = @@room_ips[params[:room].to_i]
    res = HTTParty.post("#{room_url}rotation?")
    case res.code
      when 200
        parsed_res = Nokogiri::PList(res)
        queue = parsed_res["Playlists"][0]["Playlist Items"].map {|e| {singer: e["SNGR"], artist: e["arts"], title: e["name"], siID: (e["siID"]+1)}}
        render json: queue
      when 404
        render json: "404 error"
      when 500...600
        render json: "ERROR #{response.code}"
    end    
  end

  #very similar method in private section - can these be combined?
  def get_singers #needs room as param
    room_url = @@room_ips[params[:room].to_i]
    res = HTTParty.get("#{room_url}singers")
    list = []
    case res.code
      when 200
        parsed_res = Nokogiri::PList(res)
        parsed_res["Playlists"][0]["Playlist Items"].each do |e| 
          unless (e["SNGR"].blank? || e["siID"].blank?) 
            list << {name: e["SNGR"], siID: (e["siID"]+1)}#I think it's +1 because drop has siID's 0 indexed but singers returns them 1 indexed?
          end
        end
        render json: list
      when 404
        render json: "404 error"
      when 500...600
        render json: "ERROR #{response.code}"
    end
  end

  # def get_current_song #needs room and singer
  #   room_url = @@room_ips[params[:room].to_i]
  #   response = HTTParty.post("#{room_url}command", query: {cmd_id: 23})
  #   render xml: response.body
  # end

  def move_song #needs room, singer, old_index, new_index (kjams requires parms: kPostData_PLAYLIST, kPostData_INDEX_OLD, kPostData_INDEX)
    room_url = @@room_ips[params[:room].to_i]
    login
    singer = get_singer
    response = HTTParty.post("#{room_url}reorder", body: {playlist: 2, old_index: 2, index: 1})
    render xml: response
  end

  private
  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      Rails.logger.debug("using #{token}")
      ApiKey.exists?(access_token: token)
    end
  end
  
  def get_singer(singer = nil)
    if singer == nil
      singer_to_lookup = params[:singer]
    else
      singer_to_lookup = singer
    end
    list = singers
    singer = ""
    singers.each {|e| singer = e if e[:name] == singer_to_lookup}
    return singer
  end

  def singers #needs room as param
    room_url = @@room_ips[params[:room].to_i]
    result = Nokogiri::PList(HTTParty.get("#{room_url}singers"))
    list = []
    result["Playlists"][0]["Playlist Items"].each do |e| 
      unless (e["SNGR"].blank? || e["siID"].blank?) 
        list << {name: e["SNGR"], siID: (e["siID"]+1)}#I think it's +1 because drop has siID's 0 indexed but singers returns them 1 indexed?
      end
    end
    return list
  end

  def get_user_playlists #needs room and singer as params
    room_url = @@room_ips[params[:room].to_i]
    login
    response = Nokogiri::PList(HTTParty.post("#{room_url}playlists"))
    return response
  end

  def get_kj_playlist #needs room as param
    room_url = @@room_ips[params[:room].to_i]
    response = Nokogiri::PList(HTTParty.post("#{room_url}kj_rotation"))
    return response
  end
end

#params = {singer: 'seoij'}
#for commands: http://localhost/command?cmd_id=1