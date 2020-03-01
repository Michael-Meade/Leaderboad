require "sqlite3"


task :install do 
	sh "gem install net-ssh"
	sh "apt-get install libsqlite3-dev"
	sh "gem install sqlite3"
	sh "gem install random_password"
end
task :users do
		# used to create a table called, users. 
		# column names: team_name, irn, score
		db = SQLite3::Database.new "users.db"
		db.execute <<-SQL
		create table Users (
			team_name varchar(50),
			irn varchar(50),
			score varchar(5),
			password text);
		);
		SQL
end

task :flags do 
	# checks if the flag db exists. If it doesnt
	# then it creates it
	# add flags to the databasas
	if !File.exist?('sql/flags.db')
			# flags.db doesnt exist!
			db = SQLite3::Database.new("flags.db")
			db.execute <<-SQL 
			create table Flags (
					flag varchar(50),
					points INT(50)
			);
			SQL
	end
end
###
### Rake tasks for git commit and deploy
###
##use it if you want commit only -no pushing
desc "Task description"
task :commit, :message  do |t, args|
  message = args.message
  if message==nil
    message = "Source updated at #{Time.now}."
  end
  system "git add ."
  system "git commit -a -m \"#{message}\""
end


##it will push to remote repo after commititng if any change exists
##if no change for commit, no commit will happen
##use it always
desc "commit with stagging all changes"
task :deploy, :message do |t, args|
  
  Rake::Task[:commit].invoke(args.message) 
  puts "pushing to remote:"
  system "git remote -v"
  Rake::Task[:push].execute 

  
end

#push only
desc "push to remotes"
task :push do
  system "git push -u origin master"
end
