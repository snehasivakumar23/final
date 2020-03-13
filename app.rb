# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

events_table = DB.from(:events)
rsvps_table = DB.from(:rsvps)
users_table = DB.from(:users)

get "/" do
    puts "params: #{params}"

    pp events_table.all.to_a
    @events = events_table.all.to_a
    view "events"
end

get "/gothere" do
    view "where2"

  
end

get "/events/:id" do
    puts "params: #{params}"

    pp events_table.where(id: params[:id]).to_a[0]
    @event = events_table.where(id: params[:id]).to_a[0]
    view "event"
end

get "/events/:id/rsvps/new" do
    puts "params: #{params}"

    @event = events_table.where(id: params[:id]).to_a[0]
    view "new_rsvp"
end

get "/events/:id/rsvps/create" do
    puts params
    @event = events_table.where(id: params["id"]).to_a[0]
    rsvps_table.insert(event_id: params["id"],
                       user_id: session["user_id"],
                       going: params["going"],
                       comments: params["comments"], 
                       name: params["name"],
                       email: params["email"])
    view "create_rsvp"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    puts params
    email_address = params["email"]
    password = params["password"]
    @user = users_table.where(email: email_address).to_a[0]

    if @user
        view "create_login"
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end
