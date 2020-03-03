require 'open3'
begin
	require "colorize"
rescue LoadError 
	# if colorize is NOT installed then the error is rescued and colorize is installed
	stdout, stderr, status = Open3.capture3("gem install colorize")
	if stdout.include?("Successfully installed")
		puts "Installed colorize....\n\n"
	end
end 

def self.check_gems_installed(gem_name)
	begin
		stdout, stderr, status = Open3.capture3("gem list -i '^#{gem_name}$")
	rescue => e
		puts "ERROR!\n\n\n\n\n #{e}".red
	end
end
def self.run_command(command)
	# this method runs the command that is inputed
	begin
		stdout, stderr, status = Open3.capture3(command)
	rescue
		return false
	end
end
namespace :install do
	# This namespace is used to install all the packages and gems that is needed for
	# the Player server to work.
	task :apache2 do
		# checking to see if apache2 is installed.
		checking_apache = run_command("apache2 -v")
		puts "Checking to see if apache2 is installed..."  
		if checking_apache == false
			# apache2 needs to be installed
			puts "Apache2 is not installed, but we are installing it.".red
			puts "Updating the system..."
			run_command("sudo apt-get update")
			puts "Installing apache2..."
			run_command("sudo apt-get --assume-yes install apache2")
			# Making sure that apache2 is installed.
			check_again = run_command("apache2 -v")
			if check_again.to_s.include?("Server built:")
				puts "Apache2 is now installed!\n\n\n".green
			else
				puts "Apache2 is not installed.\n\n\n"
			end
		end 
	end
	task :gems do
		# Install the needed gems for scoring server
		["net-ssh", "sinatra", "sqlite3", "random_password"].each do |gem_name|
			# if return true then gem is installed
			# if check_gems_installed(gem_name) is NOT true
			# then it will install the gem. Skips install if true
			if !check_gems_installed(gem_name)
				# Installing the gem
				puts "Installing #{gem_name}..."
				run_command("gem install #{gem_name}")
				puts "\n\n\n"
			end
		end
	end
	task :deps do
		# Installing the needed deps for the leaderboard.
		["sudo apt-get install sqlite3 libsqlite3-dev", "sudo apt-get install sqlite3"].each do |dep|
			puts "Installing #{dep}..."
			stdout, stderr, status = Open3.capture3(dep)
		end
		["sqlite3 -version"].each do |check|
			# Making sure the stuff is actually installed.
			if run_command(check)
				puts "#{check.split(" ")[0]} is Installed!\n".green
			else 
				puts "#{check.split(" ")[0]} is not Installed.\n".red
			end
		end
		puts "\n\n\n"
	end
end

namespace :cron do
	desc "Runs the script that gives the users their points."
	task :run do
		sh "ruby crontab.rb"
	end
	desc "Create a cronjob that is used for scoring."
	task :install do
		# get the current directory..
		current_directory = File.expand_path File.dirname(__FILE__)
		stdout = run_command("crontab -l")
		dir_count = 0
		stdout..to_s.split.each do |l|
			# it assumes that there should only be
			# one crontab in the file with this directory inside it.
			# it will remove any others so there is only one
			# gets the amount of times that the directory is inside the crontab
			if l.include?(current_directory)
				dir_count += 1
			end
		end
		if dir_count.to_i !=  0
			puts "Please edit crontabs and remove any other crons that have the same directory"
		else
			run_command("(crontab -l 2>/dev/null || true; echo '*/5 * * * * cd #{current_directory} && ruby crontab.rb')  | crontab -")
			puts "Installed the scoring cron job..."
		end               
	end
end


task :users do
	    require "sqlite3"
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
=begin
	task :install do 
		begin
			sh "gem install net-ssh"
			sh "gem install sinatra"
			sh "apt-get install libsqlite3-dev"
			sh "gem install sqlite3"
			sh "gem install random_password"
			sh "sudo apt-get install sqlite3 libsqlite3-dev"
			sh "sqlite3 users.db"
		rescue => e
			puts "Eror with install: #{e}"
		end
	end
=end

