require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require_relative "./model.rb"

include MyModule

enable :sessions
set :session_secret, "secret"


#   Displays Landing Page
#
#   @see Model#call_db_table
get("/") do

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
        session[:errorCode] = "unauthorized access, please loggin"
        redirect("/error")
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
    username = params["username"]
    password = params["password1"]
    password2 = params["password2"]

    session[:user] = ""
    if password != nil && password != ""
        if username != nil && password != ""
                #user login 
            if params["submit_button"] == "Login"
                # p password_test(username, password)
                session[:logged_in] = password_test(username, password)
                if password_test(username, password) == true
                    # p session[:user] = username 
                    session[:user] = username
                    redirect back
                   
                else
                    session[:errorCode] = "wrong password"
                end
            else
                    #Create user
                if params["submit_button"] == "Create user"
                    if password == password2

                        if user_exist(username) == false
                            session[:user] = username    
                            result = user_create(username, password)
                            session[:logged_in] = result
                            redirect back
                        else
                            session[:errorCode] = "Username is unavailable"
                        end
                    else
                        session[:errorCode] = "Password mismatch"
                    end
                end
            end
        else
            session[:errorCode] = "nothing is not a valid username"   
        end
    else
        session[:errorCode] = "nothing is not a valid password"   
    end
    redirect("/error")
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
    else
        session[:errorCode] = "advert text is empty"
        redirect("/error")
    end
    
    redirect("/profile/#{session[:user]}")
end

#   Sorts the adverts displayed by keywords and redirects to ether "/" or "/profile/#{session[:view_user]}"
#
#   @params [String] keyword, The keyword of the advert
#   @params [String] pagename, The pagename of the page direkts back to the right page 
post("/main_sort") do
    session[:sort_keyword] = params["keyword"]
    redirect back
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
    redirect back
end

#   Displays an error code
#
get("/error") do
    slim(:error)
end
post("/logout") do

    session.destroy
    redirect back
end

post("/loggin_create_switch") do
    if session[:keyword_switch] == nil
        session[:keyword_switch] = "create"
    else
        session[:keyword_switch] = nil
    end

    redirect back
end
