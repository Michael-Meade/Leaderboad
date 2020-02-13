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
			p row
			puts ":::::::::::::::::::::::::"
			if row[0].nil?
				# its is not nil meaning
				# the team exists. Returing 0
				return true
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
			#Creating account by inserting into the table
			Users_db.execute("INSERT INTO Users (team_name, irn, score) 
            VALUES (?, ?, ?)", [team_name, irn, "0"])
		end
	end
end

puts DB.create_username("mike", "kik")