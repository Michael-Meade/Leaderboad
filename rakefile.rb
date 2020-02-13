require "sqlite3"


task :users do
		# used to create a table called, users. 
		# column names: team_name, irn, score
		db = SQLite3::Database.new "users.db"
		db.execute <<-SQL
		create table Users (
			team_name varchar(50),
			irn varchar(50),
			score varchar(5)
		);
		SQL
end