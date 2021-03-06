namespace :weather_rooster do
  desc "Pull the latest forecasts from the weather services"
  task :pull_latest_forecasts => :environment do
    if ARGV.size > 1
      flag = ARGV.last
      task flag.to_sym do ; end
    end
    if defined?(flag) && flag == "all"
      services = WeatherService.all
    else
      services = WeatherService.where(:active => true)
   end
    cities = City.all
    cities.each do |c|
      services.each do |s|
        begin
          s.pull_latest_forecast(c)
          Rails.logger.info "Successfully pulled current forecast for #{s.short_name}:#{c.name}"
        rescue Exception => ex
          Rails.logger.error "Error pulling current forecast for #{s.short_name}:#{c.name} - #{ex}"
        end
      end
      sleep 1
    end
  end

  desc "Pull the latest actual data from NOAA"
  task :pull_latest_actual => :environment do
    NOAA.pull_latest_data(City.all)
  end

  desc "Pull next-day forecasts for eastern locations"
  task :pull_tomorrow_eastern => :environment do
    WeatherService.pull_all_tomorrow("Eastern Time (US & Canada)")
  end

  desc "Pull next-day forecasts for central locations"
  task :pull_tomorrow_central => :environment do
    WeatherService.pull_all_tomorrow("Central Time (US & Canada)")
  end

  desc "Pull next-day forecasts for mountain locations"
  task :pull_tomorrow_mountain => :environment do
    WeatherService.pull_all_tomorrow("Mountain Time (US & Canada)")
  end

  desc "Pull next-day forecasts for pacific locations"
  task :pull_tomorrow_pacific => :environment do
    WeatherService.pull_all_tomorrow("America/Los_Angeles")
  end
end
