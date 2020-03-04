require_relative 'sql/db'
require_relative 'lib/lb'
require 'httparty'
begin
	response  = HTTParty.get("http://google.com")
	#team_name = response.parsed_response.to_s
	#DB.add_points(team_name)
	test_error
rescue => e
	puts ":::::"
	Alerts.check_status(e, "cron.rb")
end