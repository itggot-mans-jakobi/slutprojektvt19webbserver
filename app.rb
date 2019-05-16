require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require_relative "./model.rb"

include MyModule

enable :sessions
set :session_secret, "secret"

get("/") do
    # session[:debug] = "luawdioanhwd"
    p "------"
    p session[:logged_in]
    p "------"
    p session[:debug]
    p "------"

    slim(:index)
end


post("/user_login") do

    session[:logged_in] = "somenicetexttodebug"
    p session[:logged_in]
 
    p session[:debug]

    redirect("/")
end

