require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require_relative "functions.rb"
# require_relative ""

enable :sessions    

get("/") do

    session[:adverts_main] = call_db_table("adverts")

    slim(:index)
end

# get("/profile") do

#     slim(:profile)
# end

get("/:user") do
    session[:view_user] = params["user"]

    slim(:profile)
end

post("/user_login") do
    username = params["username"]
    password = params["password1"]
    
    if password != nil 
                #user login 
        if params["submit_button"] == "Login"
            if password_test(username, password) == true
                session[:logged_in] = true
                session[:user] = username
                
                redirect("/")
            end
        else
                #Create user
            if params["submit_button"] == "Create user"
                user_create(username, password)
            end
        end
    end
    redirect("/")
end

post("/ad_new") do
    adtext = params["adtext"]
    if adtext != ""
        ad_create(session[:user],adtext , params["adpicture"])
    end
    redirect("/#{session[:user]}")
end