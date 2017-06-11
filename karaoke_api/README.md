# README

need to create postgres db:

createdb -E UTF8 -T template0 api_server_dev

start server:

rails server -b 0.0.0.0 -p 3030



FIRST TIME:
seed db with queues: 
[1,2,3,4,5,6].each {|room| SongQueues.new({room: room}).save}

To generate a new API key for the web app.
a = ApiKey.create
a.access_token
#copy resultant hash to production servers as needed!
for ex: heroku config:set ONSITE_API_KEY="access_token_goes_here"

api key use:
HTTParty example:
headers: {"Authorization" => "Token token=\"111\""}
headers: {authorization: "Token token=#{ENV['ONSITE_API_KEY']}")





* /custom_kjams_files

Replace the XML files in /Library/preferences/kjams/Producer Templates
Replace the rotation_background.png in /Library/preferences/kjams/Producer Templates/pix
Mimic the settings in kjams_settings.png

