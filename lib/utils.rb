require 'json'
class Utils
	def self.read_confg(value)
		read = JSON.parse(File.read("config.json"))[value]
	end
	def self.signup_switch
		read = JSON.parse(File.read("config.json"))["signup"]
		return true if read == "true"
	end
end