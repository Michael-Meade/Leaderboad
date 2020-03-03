require_relative 'sql/db'
require 'httparty'
<<<<<<< HEAD
response  = HTTParty.get("http://159.65.216.57/")
team_name = response.parsed_response.to_s
DB.add_points(team_name)
=======
response  = HTTParty.get("IP")
team_name = response.parsed_response.to_s
DB.add_points(team_name)
>>>>>>> c30d3cec218932ab5f1c1ebc625fd5524793a7ce
