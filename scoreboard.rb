require 'sinatra'
# import the sql class
require_relative 'sql/db'
#ruby server.rb -p $PORT -o $IP
post '/signup' do
    team_name = params[:t_name]
    real_name = params[:irn]
    # making sure team_name AND real_name is not empty
    if team_name.empty? || real_name.empty?
        "error"
    else
        SQL.create_user(team_name, real_name)
        redirect '/LeaderBoard'
    end
end
get '/signup' do
    erb :'signup'
end
get '/LeaderBoard' do
    erb :'leaderBoard'
end
