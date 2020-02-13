require 'sinatra'
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
end
get '/signup' do
    erb :'signup'
end
get '/LeaderBoard' do
    erb :'leaderBoard'
end
