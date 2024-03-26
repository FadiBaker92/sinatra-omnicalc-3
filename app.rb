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
  pirate_weather_url = "https://api.pirateweather.net/forecast/#{ENV["PIRATE_WEATHER_KEY"]}/#{@latitude},#{@longitude}"
  pirate_raw_result = HTTP.get(pirate_weather_url).to_s
  pirate_parsed_result = JSON.parse(pirate_raw_result)
  @pirate_temperature = pirate_parsed_result.dig("currently" , "temperature")
  @pirate_summ = pirate_parsed_result.dig("currently" , "summary")

  precip_prob_threshold = 0.10
  @any_precipitation = false
  hourly_hash = pirate_parsed_result.fetch("hourly")
  hourly_data_array = hourly_hash.fetch("data")
  next_twelve_hours = hourly_data_array[1..12]
  
  next_twelve_hours.each do |hour_hash| 
    precip_prob = hour_hash.fetch("precipProbability")
    if precip_prob > precip_prob_threshold
      @any_precipitation = true 
    end
  end



  erb(:umbrella_results)
end
