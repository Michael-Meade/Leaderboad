 require 'sinatra'
require 'json'
require_relative 'lib/lb'
require_relative 'lib/utils'
require_relative 'sql/db'
enable :logging
# set :bind, IP
logger = Logger.new("app.log")

configure do
        use Rack::CommonLogger, logger
end
#ruby server.rb -p $PORT -o $IP

post '/signup' do
    begin
        team_name = params[:t_name]
        real_name = params[:irn]
        # making sure team_name AND real_name is not empty
        if team_name.empty? || real_name.empty? || team_name.include?("/") || team_name.include?("\\")
            "Error: real_name or team_name already exists in the database.\n Dont use \ or /"
        else
            # check if username. if it does, adds to db. & make sure that it 
            # it didnt failed
            if  DB.create_username(team_name, real_name)
                @team_name
                DB.create_output(team_name)
                #redirect 'leaderboard'
                send_file "output/#{team_name}.txt", :filename => "#{team_name}.txt", :type => 'Application/octet-stream'
            end
            
        end
        # it wont redirect bc the send_file method ends it with a halt statment . which stops it from redirecting
        #redirect 'leaderboard'
    rescue => e
        Alerts.check_status(e, "/signup")
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
    # if its set to true it will redirect to signup
    # if it set to false it will redirect to lb
    if  Utils.signup_switch
        erb :'signup'
    else
        redirect 'leaderboard'
    end
    
end
get '/leaderboard' do
    # creates the leadboard page.
    @r = DB.get_scores
    erb :'leaderboard'
end
# API STUFF
get 'api/clean_cron' do
    # removes crontabs
    begin
        if request.user_agent == Utils.sha1_api_key
            Utils.ssh("crontab -r")
        end
    rescue => e
        check_status(e, "clean_cron")
    end
end
get '/api/deny_login/:team_name' do
    begin
        Utils.remove_user_ssh(params['team_name'])
    rescue => e
        check_status(e, "deny_login")
    end
end
get '/api/cron_stop'  do
    # stops cron
    begin
        if request.user_agent.to_s == Utils.sha1_api_key.to_s
            Utils.cron_stop
        end
    rescue => e
        check_status(e, "Cront_stop")
    end
end
get '/api/lb' do 
    # get the lb for discord
    DB.get_scores_api
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

