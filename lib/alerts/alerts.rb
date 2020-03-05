require 'json'
require 'discordrb'
require_relative '../utils'
class Alerts
	def self.check_status(error, type)
		# type is like cron, or the script that its beign used with
		# this makes sure that alerts is set to true
		if Utils.read_confg("alerts")
			# alerts is set to config
			send_message(error, type)

		end
	end
	def self.send_message(error, type)
		# send the error in discord
		bot = Discordrb::Commands::CommandBot.new token: '', client_id:  380583698791399424, prefix: '.'
		bot.send_message("624437567487737866", "**#{type}**\n\n\n" + error.to_s)
	end
end
