require "sqlite3"
require 'random_password'
require 'net/ssh'
class DB
	# load the db
	Users_db = SQLite3::Database.new "users.db"
	def self.check_username(team_name)
		# make sure the team_name and
		# the real_name is not already taken.
		Users_db.execute( "select team_name, irn from users where team_name='#{team_name}'" ) do |row|
			# row[0] => team_name
			# row[1] => irn
			p row
			if row[0].nil?
				# its is not nil meaning
				# the team doesnt exists.
				return true
			else 
				# the team name exists :(
				return false
			end
		end		
	end
	def self.add_user(team_name, pass)
		#useradd -p encrypted_password newuser
		#usermod -a -G dew newuser
		# SSH into the ctf VPS and creates a user account.
		Net::SSH.start('159.65.216.57', 'root', :password => "") do |ssh|
			# creates user and adds password. 
			output = ssh.exec!("useradd #{team_name} -p x ")
			ssh.exec!("cp -rv /root/.ssh/ /home/#{team_name}")
			ssh.exec!("chmod g-w /home/#{team_name}")
			ssh.exec!("chmod 700 /home/#{team_name}/.ssh")
			ssh.exec!("chmod 600 /home/#{team_name}/.ssh/authorized_keys")
			ssh.exec!("echo '#{team_name}:#{pass}' | chpasswd")
			ssh.exec!("sed -i '/^AllowUsers/ s/$/ '#{team_name}'/' /etc/ssh/sshd_config")
			ssh.exec!("sudo service ssh restart")
			
			#Utils.add_user_ssh(team_name)

		end

	end
	def self.create_username(team_name, irn)
		# checks to make sure the name doesnt exist. If it returns nil 
		# then we know that it doesnt exist.
		# everyone starts with a score of 0
		check = check_username(team_name)
		if check.nil?
			# username does not exist... 
			# Creating account by inserting into the table
			random_password = RandomPassword.new(length: 10, digits: 4, symbols: 4)
			pass = random_password.generate
			Users_db.execute("INSERT INTO Users (team_name, irn, score, password) 
            VALUES (?, ?, ?, ?)", [team_name, irn, "0", pass])
            add_user(team_name, pass)
		end
	end
	def self.create_output(team_name)
		# create an file that the user downloads
		# file contains account information ( to login, etc )
		f = File.open("output/#{team_name}.txt", "w")
		Users_db.execute( "select * from users where team_name='#{team_name}'" ) do |row|
			f.write("Team Name: #{row[0]}\n IRN: #{row[1]}\n pass: #{row[3]}")
			f.close
		end
	end
	def self.add_points(team_name)
		# if the user finds a correct flag.
		# this method will give the team their points
		check = check_username(team_name)
		# checking to make sure the team name exists
		if check == false
			# it does exist.
			Users_db.execute("UPDATE Users SET score = score + 50 WHERE team_name = '#{team_name}'")
			# updated users score.
		end
	end
	def self.get_scores
		# create a hash of all the rows and scores.
		Users_db.execute("select team_name, score from Users order by score desc")
	end
end

