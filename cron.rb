require_relative 'sql/db'
require 'httparty'
response  = HTTParty.get("IP")
team_name = response.parsed_response.to_s
DB.add_points(team_name)
