require 'sinatra'
require 'json'
require_relative 'lib/utils'
require_relative 'sql/db'
#ruby server.rb -p $PORT -o $IP
post '/signup' do
    team_name = params[:t_name]
    real_name = params[:irn]
    puts team_name
    # making sure team_name AND real_name is not empty
    if team_name.empty? || real_name.empty?
        "error"
    else
        # check if username. if it does, adds to db.
        DB.create_username(team_name, real_name)
    end
    redirect 'leaderboard'
end
get '/api/enable_signup' do
    # This enables signup. This will cause the index page to be redirected
    # to the signup page.
    read = JSON.parse(File.read("config.json"))["signup"]
    if read == "false"
        read = JSON.parse(File.read("config.json"))
        read["signup"] = "true"
        f = File.open("config.json", "w")
        f.write(read.to_json)
        f.close
    end
end
get  '/api/disable_signup' do
    # disables signup. This will cause the index page to be redirected
    # to leaderboard page.
    read = JSON.parse(File.read("config.json"))["signup"]
    if read == "true"
        read = JSON.parse(File.read("config.json"))
        # changes signup to disabled in the config file
        read["signup"] = "false"
        f = File.open("config.json", "w")
        f.write(read.to_json)
        f.close

    end
end
get '/' do
    # if signups are enabled redirect to the signup page
    # if signups are disabled redirect ot the leaderboard.
    read = JSON.parse(File.read("config.json"))["signup"]
    if read == "true"
        redirect 'signup'
    elsif read == "false"
        redirect "leaderboard"
    end
end
get '/signup' do
    erb :'signup'
    
end
get '/leaderboard' do
    # creates the leadboard page.
    @r = DB.get_scores
    erb :'leaderboard'
end
