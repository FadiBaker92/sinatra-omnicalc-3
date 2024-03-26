require "sinatra"
require "sinatra/reloader"
require "http"

get("/") do
  erb(:homepage)
end

get("/umbrella") do
  erb(:umbrella_form)
end

post("/process_umbrella") do
  @user_location = params.fetch("user_loc")
  user_location_gsub = @user_location.gsub(" ", "+")
  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location_gsub}&key=#{ENV["GMAPS_KEY"]}"
  raw_results = HTTP.get(gmaps_url).to_s
  @parsed_result = JSON.parse(raw_results)
  @result_location = @parsed_result.dig("results", 0, "geometry", "location")
  @latitude = @result_location.fetch("lat")
  @longitude = @result_location.fetch("lng")
    

  erb(:umbrella_results)
end
