require 'bundler/inline'
require 'fileutils'
require_relative 'lib/strings'
require 'open3'
def self.check_installed(gem_name)
	begin
		stdout, stderr, status = Open3.capture3("gem list -i '^#{gem_name}$")
	rescue => e
		puts "ERROR!\n\n\n\n\n #{e}"
	end
end
def self.run_command(command)
	# this method runs the command that is inputed
	begin
		stdout, stderr, status = Open3.capture3(command)
	rescue
		puts stdout
		puts "L:L"
	end
end
gemfile do
  source 'https://rubygems.org'
  gem 'colorize', require: true
  gem 'net-ssh', require: false
  gem 'sinatra', require: false
  gem 'sqlite3', require: true
  gem 'httparty', require: false
  gem 'discordrb', require: false
  gem 'sqlite-devel', require: false
  gem 'random_password', require: false

 


gem update
  gem 'random_password', require: false
end
puts "Installed the needed gems".green
["sudo apt-get install sqlite3 libsqlite3-dev", "sudo apt-get install sqlite3"].each do |dep|
	stdout, stderr, status = Open3.capture3(dep)
end
["sqlite3 -version"].each do |check|
	# Making sure the stuff is actually installed.
	if run_command(check)
		puts "#{check.split(" ")[0]} is Installed!".green
	else 
		puts "#{check.split(" ")[0]} is not Installed.".red
	end
end


# creating the cron job that will give users 
# their points
puts "Creating the crontab for scoring. ".green
# Get the current directory 
current_directory = File.expand_path File.dirname(__FILE__)
run_command("(crontab -l 2>/dev/null || true; echo '*/1 * * * * cd #{current_directory} && ruby crontab.rb')  | crontab -")
puts "Crontab has been added.\n".green

# create the database used for the scoreboard
db = SQLite3::Database.new "users.db"
db.execute <<-SQL
create table Users (
	team_name varchar(50),
	irn varchar(50),
	score varchar(5),
	password text);
);
SQL
puts "Created users.db\n".green


# create output folder
FileUtils.mkdir_p 'output'