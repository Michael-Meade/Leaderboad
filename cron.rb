require_relative 'sql/db'
require_relative 'lib/lb'
require 'httparty'
begin
	response  = HTTParty.get("http://159.65.216.57")
	team_name = response.parsed_response.to_s
	puts team_name
	p response.code
	if response.code.to_s == "403"
		# if cant access to scoring file
		# will send message in discord channel that
		# will alert admin of errors, if its enabled in the configs
		Alerts.check_status("403 error with scoring file.", "cron.rb")
	else
		puts ":::"
		# everything goes right and the users get their pooints.
		DB.add_points(team_name)
	end
rescue => e
	# alert the asdmin that there was a error with scoring.
	# sends alert in discord channels
	Alerts.check_status(e, "cron.rb")
end

