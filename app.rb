require "sinatra"
require "sinatra/reloader"
require "http"

get("/") do
  "
  <h1>Welcome to your Sinatra App!</h1>
  <p>Define some routes in app.rb</p>
  "
end

get("/umbrella") do
  erb(:umbrella_form)
end

get("/process_umbrella") do
  @user_location = params.fetch("user_loc")
  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@user_location}&key=#{ENV["GMAPS_KEY"]}"
  raw_results = HTTP.get(gmaps_url).to_s
  @parsed_result = JSON.parse(raw_results)

  erb(:umbrella_results)
end
