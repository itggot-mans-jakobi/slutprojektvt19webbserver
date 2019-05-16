require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require_relative "./model.rb"

include MyModule

enable :sessions
set :session_secret, "secret"




# enable :sessions  
# set :session_secret, "My session secret"

# set :session_secret, "something"
# set :session_secret, "328479283uf923fu8932fu923uf9832f23f232"


# use Rack::Session::Cookie

#   Displays Landing Page
#
#   @see Model#call_db_table
get("/") do
    # session[:debug] = "luawdioanhwd"
    p "------"
    p session[:logged_in]
    p "------"
    p session[:debug]
    p "------"

    if session[:sort_keyword] == nil
        session[:sort_keyword] = "all"
    end

    session[:adverts_main] = call_db_table("adverts")
    
    slim(:index)
end

#   Displays all adverts by a particular user
#
#   @params [String] user, The username of a user
get("/profile/:user") do
    if session[:logged_in] != true || params["user"] == "?"
        redirect("/")
    end
    session[:view_user] = params["user"]

    slim(:profile)
end

#   Displays the landingpage if the sought after username is "?"
#
get("/profile/?") do
    slim(:index)
end

#   Checks if a password of a user is the same as in the database and creates a user if the username is not taken and redirects to "/" 
#
#   @params [String] username, The inputed username of a user
#   @params [String] password1, The inputed password of a user
#   @params [String] submit_button, Differentiate between "Login" or "create user" 
#
#   @see Model#password_test
#   @see Model#user_create
post("/user_login") do
    # username = params["username"]
    # password = params["password1"]
    session[:logged_in] = "somenicetexttodebug"
    p session[:logged_in]
    # session[:debug] = "string"
    p session[:debug]
    # session[:user] = ""
    # if password != nil 

    #             #user login 
    #     if params["submit_button"] == "Login"
    #         # p password_test(username, password)
    #         session[:logged_in] = password_test(username, password)
    #         if password_test(username, password) == true
    #             session[:user] = username
    #             p "debug 1"

    #         end
    #     else
    #             #Create user
    #         if params["submit_button"] == "Create user"
    #             if user_exist(username) != true
    #                 session[:user] = username    
    #                 result = user_create(username, password)
    #                 p result
    #                 session[:logged_in] = result
    #             end
    #         end
    #     end
    # end
    
    redirect("/")
end

#   Creates a new advert if the advert contains characters
#
#   @params [String] adtext, The text of the advert
#   @params [String] adpicture, The picture of the advert
#   @params [String] keyword, The keyword of the advert
#
#   @see Model#ad_create
post("/ad_new") do
    adtext = params["adtext"] 
    if adtext != ""
        ad_create(session[:user],adtext , params["adpicture"], params["keyword"])
    end
    redirect("/profile/#{session[:user]}")
end

#   Sorts the adverts displayed by keywords and redirects to ether "/" or "/profile/#{session[:view_user]}"
#
#   @params [String] keyword, The keyword of the advert
#   @params [String] pagename, The pagename of the page direkts back to the right page 
post("/main_sort") do
    session[:sort_keyword] = params["keyword"]
    if params["pagename"] == "profile"
        redirect("/profile/#{session[:view_user]}")
    else
        redirect("/")
    end
end

#   Displays a specific advert
#
#   @params [String] postid, The id of a specific advert
get("/post/:postid") do
    session[:view_post] = params["postid"]

    slim(:advert)
end

#   Creates a bid on a specific advert and redirects to "/"
#
#   @params [String] quantity, The value of the bid
#
#   @see Model#bid
post("/bid") do
    bid(session[:user], session[:view_post], params["quantity"])
    redirect("/")
end

get("/error") do

    slim(:error)
end


