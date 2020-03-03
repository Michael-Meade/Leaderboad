require_relative 'sql/db'
require 'httparty'
response  = HTTParty.get("http://159.65.216.57/")
team_name = response.parsed_response.to_s
DB.add_points(team_name)