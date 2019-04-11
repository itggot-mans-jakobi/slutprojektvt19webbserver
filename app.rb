require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require_relative "functions.rb"
# require_relative ""

enable :sessions    

get("/") do
    # result = call_db_table()

    slim(:index)
end

post("/user_login") do
    username = params["username"]
    password = params["password"]

            #user login 
    if params["submit_button"] == "Login"
        if password_test(username, password) == true
            session[:logged_in] = true
            session[:user] = username
            
            redirect("/")
        end
    elsif
            #Create user
        if params["submit_button"] == "Create user"
            user_create(username, password)
        end
    end
    redirect("/")
    
end