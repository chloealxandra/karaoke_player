class QueueController < ApplicationController

  def index
    @queues = ["dashboard probably goes here"]
  end

  def show
    room_url = @@room_ips[params[:room].to_i]
    response = Plist::parse_xml(HTTParty.post("#{room_url}rotation?"))
    queue = response["Playlists"][0]["Playlist Items"].map {|e| {singer: e["SNGR"], artist: e["arts"], title: e["name"], siID: (e["siID"]+1)}}
    @queue = queue
  end
  
end