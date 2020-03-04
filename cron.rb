require_relative 'sql/db'
require_relative 'lib/lb'
require 'httparty'
begin
	response  = HTTParty.get("IP")
	team_name = response.parsed_response.to_s
	DB.add_points(team_name)
rescue => e
	Alerts.check_status(e, "cron.rb")
end