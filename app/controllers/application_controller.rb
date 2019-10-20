class ApplicationController < ActionController::Base
  require 'open_weather'

  def index
    ip = if Rails.env.production?
           request.remote_ip
         else
           Net::HTTP.get(URI.parse('http://checkip.amazonaws.com/')).squish
         end
    results = Geocoder.search(ip)
    city = results.first.city
    country = results.first.country
    @place = if city.eql?(country)
               city.upcase
             else
               city.upcase + ', ' + country
             end
    options = { units: "metric", APPID: "1ccb7f1abe3bee00d93171819b93ff9d", cnt: 3 }
    @weather = OpenWeather::Forecast.geocode(results.first.latitude,
                                      results.first.longitude,
                                      options)

  end

  def search
    if params[:search][:city].present?
      redirect_to forecast_path(params[:search][:city])
    else
      render :search
    end
  end

  def weather

  end

  def forecast
    attemps = 0
    begin
      @response = response.status
      city = params[:format]
      country = Geocoder.search(params[:format]).first.country
      @place = if city.eql?(country)
        city.upcase
      else
        city.upcase + ', ' + country
      end
      options = { units: "metric", APPID: "2bde50bdcc809a6230f17e9ba8e7f951"}
      results = Geocoder.search(city)
      weather = OpenWeather::Forecast.geocode(results.first.latitude,
                                              results.first.longitude,
                                              options)
      forecast_array = []
      weather['list'].each do |forecast|
        forecast_array.push(date: forecast['dt_txt'].to_date, tmp: forecast['main']['temp'], weather: forecast['weather'][0]['main'])
      end
      forecast = forecast_array.group_by {|d| d[:date]}
      @weather = []
      forecast.each do |k, v|
        temp = v.group_by {|x| x[:tmp]}.keys
        weather = v.group_by {|x| x[:weather]}.keys
        @weather.push(date: k, tmp: (temp.reduce(:+)/temp.count).round(1), weather: weather[0])
      end
    rescue
      attemps += 1
      if results.nil? && attemps < 3
        retry
      else
        @weather = nil
      end
    end
  end
end
