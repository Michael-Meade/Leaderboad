require 'json'
require 'net/ssh'
require 'json'
require 'digest/sha1'
class Utils
	def self.read_confg(value)
		read = JSON.parse(File.read("config.json"))[value]
	end
	def self.signup_switch
		read = JSON.parse(File.read("config.json"))["signup"]
		return true if read == "true"
	end
	def self.sha1_api_key
		Digest::SHA1.hexdigest(JSON.parse(File.read("config.json"))["api-key"].to_s)
	end
	def self.remove_user_ssh(team_name)
		read = File.read("/etc/ssh/sshd_config")
		File.readlines("/etc/ssh/sshd_config").each do |line|
			if line.match("AllowUsers")
				puts line
				@new_line = line.gsub(team_name, " ")
			end
		end
		changed = read.gsub(@new_line, @new_line.strip + " " + team_name.strip + "\n")
		f = File.open("/etc/ssh/sshd_config", "w")
		f.write(changed)
		f.close
	end
	def self.add_user_ssh(team_name)
		read = File.read("/etc/ssh/sshd_config")
		File.readlines("/etc/ssh/sshd_config").each do |line|
			if line.match("AllowUsers")
				 @new_line = "AllowUsers" + line.split("AllowUsers").join
			end
		end
		# adds the team_name to the AllowedUsers
		changed = read.gsub(@new_line, @new_line.strip + " " + team_name.strip + "\n")
		f = File.open("/etc/ssh/sshd_config", "w")
		f.write(changed)
		f.close
	end
	def self.ssh(command, arg=nil)
		# sshs into ctf server & runs commands
		# used to make game fair
		Net::SSH.start('159.65.216.57', 'root', :password => "") do |ssh|
			# creates user and adds password. 
			output = ssh.exec!(command)
			return output if !arg.nil?
		end
	end
end
