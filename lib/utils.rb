require 'json'
class Utils
	def self.read_confg(value)
		read = JSON.parse(File.read("config.json"))[value]
	end
end