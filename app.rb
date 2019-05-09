require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require_relative "model.rb"
include MyModule

enable :sessions    

# before do
#     # if session[:logged_in] != true
#     #     redirect("/")
#     # end
# end

get("/") do
    if session[:sort_keyword] == nil
        session[:sort_keyword] = "all"
    end
    session[:adverts_main] = call_db_table("adverts")

    slim(:index)
end

get("/profile/:user") do
    if session[:logged_in] != true || params["user"] == "?"
        redirect("/")
    end
    session[:view_user] = params["user"]

    slim(:profile)
end

get("/profile/?") do
    slim(:index)
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
        ad_create(session[:user],adtext , params["adpicture"], params["keyword"])
    end
    redirect("/profile/#{session[:user]}")
end

post("/main_sort") do
    session[:sort_keyword] = params["keyword"]
    if params["pagename"] == "profile"
        redirect("/profile/#{session[:view_user]}")
    else
        redirect("/")
    end
end

get("/post/:postid") do
    session[:view_post] = params["postid"]

    slim(:advert)
end

post("/bid") do
    bid(session[:user], session[:view_post], params["quantity"])
    redirect("/")
end
