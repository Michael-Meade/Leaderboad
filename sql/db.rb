require "sqlite3"
require 'random_password'
require 'net/ssh'
require 'json'
require_relative '../lib/lb'
class DB
	# load the db
	Users_db = SQLite3::Database.new "users.db"
	def self.check_username(team_name)
		# make sure the team_name and
		# the real_name is not already taken.
		begin
			Users_db.execute( "select team_name, irn from users where team_name='#{team_name}'" ) do |row|
				# row[0] => team_name
				if row[0].nil?
					# the team doesnt exists.
					puts "tre"
					return true
				else 
					# the team name exists
					puts ":::"
					return false
				end
			end
		rescue => e
			Alerts.check_status(e, "\\sql\\db.rb - check_username(team_name)")
		end		
	end
	def self.add_user(team_name, pass)
		begin
			# SSH into the ctf VPS and creates a user account.

			Net::SSH.start(Utils.read_confg("ssh-ip").to_s, 'root', :password => Utils.read_confg("ssh-pass").to_s) do |ssh|
				# creates user and adds password. 
				output = ssh.exec!("useradd #{team_name} -p x ")
				ssh.exec!("cp -rv /root/.ssh/ /home/#{team_name}")
				ssh.exec!("chmod g-w /home/#{team_name}")
				ssh.exec!("chmod 700 /home/#{team_name}/.ssh")
				ssh.exec!("chmod 600 /home/#{team_name}/.ssh/authorized_keys")
				ssh.exec!("echo '#{team_name}:#{pass}' | chpasswd")
				ssh.exec!("sed -i '/^AllowUsers/ s/$/ '#{team_name}'/' /etc/ssh/sshd_config")
			end
		rescue => e
			Alerts.check_status(e, "\\sql\\db.rb - add_user(team_name, pass)")
		end

	end
	def self.create_username(team_name, irn)
		# checks to make sure the name doesnt exist. If it returns nil 
		# then we know that it doesnt exist.
		# everyone starts with a score of 0
		begin
			check = self.check_username(team_name)
			if check.nil?
				# username does not exist... 
				# Creating account by inserting into the table
				puts ":::"
				random_password = RandomPassword.new(length: 10, digits: 4, symbols: 4)
				pass = random_password.generate
				Users_db.execute("INSERT INTO Users (team_name, irn, score, password) 
	            VALUES (?, ?, ?, ?)", [team_name, irn, "0", pass])
	            # SSH into the players box and creates the username
	            add_user(team_name, pass)
	            @results = true
			end
		rescue => e
			Alerts.check_status(e, "\\sql\\db.rb - create_username(team_name, irn)")
			return false
		end
	end
	def self.create_output(team_name)
		# create an file that the user downloads
		# file contains account information ( to login, etc )
		begin
			f = File.open("output/#{team_name}.txt", "w")
			Users_db.execute( "select * from users where team_name='#{team_name}'" ) do |row|
				f.write("Team Name: #{row[0]}\n IRN: #{row[1]}\n pass: #{row[3]}")
				f.close
			end
		rescue => e
			Alerts.check_status(e, "\\sql\\db.rb - create_output(team_name)")
		end
	end
	def self.add_points(team_name)
		# if the user finds a correct flag.
		# this method will give the team their points
		begin
			check = check_username(team_name)
			# checking to make sure the team name exists
			if check.to_s == false.to_s
				# it does exist.
				Users_db.execute("UPDATE Users SET score = score + 50 WHERE team_name = '#{team_name.strip}'")
				# updated users score.
			end
		rescue => e
			Alerts.check_status(e, "\\sql\\db.rb - add_points(team_name)")
		end
	end
	def self.get_scores_api
		# creates the hash instance 
		# this method is used to get the top 10 users 
		# used for the api.
		begin
			lb = {}
			count = 0
			Users_db.execute("select team_name, score from Users order by score desc").each do |row|
				if count.to_i <= 10
					lb[count.to_i] = [row[0], row[1]]
					count += 1
				end
			end
		lb.to_json
		rescue => e
			Alerts.check_status(e, "\\sql\\db.rb - get_scores_api")
		end
	end
	def self.get_scores
		# create a hash of all the rows and scores.
		Users_db.execute("select team_name, score from Users order by score desc")
	end
end