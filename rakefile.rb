require "sqlite3"


task :users do
		# used to create a table called, users. 
		# column names: team_name, irn, score
		db = SQLite3::Database.new "sql/users.db"
		db.execute <<-SQL
		create table Users (
			team_name varchar(50),
			irn varchar(50),
			score varchar(5)
		);
		SQL
end

task :flags do 
	# checks if the flag db exists. If it doesnt
	# then it creates it
	# add flags to the databasas
	if !File.exist?('sql/flags.db')
			# flags.db doesnt exist!
			db = SQLite3::Database.new("sql/flags.db")
			db.execute <<-SQL 
			create table Flags (
					flag varchar(50),
					points INT(50)
			);
			SQL
	end
end