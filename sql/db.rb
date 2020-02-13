require "sqlite3"
class DB
	# load the db
	Users_db = SQLite3::Database.new "users.db"
	def self.check_username(team_name)
		# make sure the team_name and
		# the real_name is not already taken.
		Users_db.execute( "select team_name, irn from users where team_name='#{team_name}'" ) do |row|
			# row[0] => team_name
			# row[1] => irn
			if row[0].nil?
				# its is not nil meaning
				# the team exists. Returing 0
				return true
			else 
				return false
			end
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
			Users_db.execute("INSERT INTO Users (team_name, irn, score) 
            VALUES (?, ?, ?)", [team_name, irn, "0"])
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
end
DB.add_points("mike")
#puts DB.create_username("mike", "kik")