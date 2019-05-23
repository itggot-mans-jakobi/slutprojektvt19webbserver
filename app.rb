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

#   Displays all adverts by a particular user, and redirects to "/error" i an error occurs 
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

#   Checks if a password of a user is the same as in the database and creates a user if the username is not taken redirects back to te previus page and redirects to "/error" i an error occurs 
#
#   @params [String] username, The inputed username of a user
#   @params [String] password1, The first inputed password of a user
#   @params [String] password2, The second inputed password of a user
#   @params [String] submit_button, Differentiate between "Login" or "create user" 
#
#   @see Model#password_test
#   @see Model#user_create
#   @see Model#user_exist
post("/user_login") do
    username = params["username"]
    password = params["password1"]
    password2 = params["password2"]

    session[:user] = ""
    if password != nil && password != ""
        if username != nil && password != ""
                #user login 
            if params["submit_button"] == "Login"
                if user_exist(username) == true
                    session[:logged_in] = password_test(username, password)
                    if password_test(username, password) == true
                        session[:user] = username
                        session[:errorCode] = nil
                        redirect back
                    else
                        session[:errorCode] = "wrong password"
                    end
                else
                    session[:errorCode] = "User does not exist"   
                end
            else
                    #Create user
                if params["submit_button"] == "Create user"
                    if password == password2
                        if user_exist(username) == false
                            session[:user] = username    
                            result = user_create(username, password)
                            session[:logged_in] = result
                            session[:errorCode] = nil
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

#   Creates a new advert if the advert contains characters and redirects to "/error" i an error occurs
#
#   @params [String] adtext, The text of the advert
#   @params [String] adpicture, The picture of the advert
#   @params [String] keyword, The keyword of the advert
#
#   @see Model#ad_create
post("/ad_new") do
    adtext = params["adtext"] 
    adpicture = params["adpicture"]
    if adtext != ""
        ad_create(session[:user] ,adtext ,adpicture , params["keyword"])
    else
        session[:errorCode] = "advert text is empty"
        redirect("/error")
    end
    
    redirect("/profile/#{session[:user]}")
end
post("/ad_update") do
    adtext = params["adtext"] 
    adpicture = params["adpicture"]
    if adtext != ""
        ad_uppdate(session[:user], adtext, adpicture)
    else
        session[:errorCode] = "advert text is empty"
        redirect("/error")
    end
end

post("/ad_uppdate") do
    adtext = params["adtext"] 
    adpicture = params["adpicture"]
    if adtext != ""


        ad_create(session[:user] ,adtext ,adpicture , params["keyword"])
    else
        session[:errorCode] = "advert text is empty"
        redirect("/error")
    end
    
    redirect("/profile/#{session[:user]}")
end


#   Sorts the adverts displayed and redirects back to te previus page
#
#   @params [String] keyword, The keyword of the advert
post("/main_sort") do
    session[:sort_keyword] = params["keyword"]
    redirect back
end

#   Displays a specific advert
#
#   @params [String] postid, The id of a specific advert
get("/post/:postid") do
    session[:view_post] = params["postid"]
    p params["edit"]
    p "......"
    if params["edit"] == "true"
        result = true
    end
    slim(:advert, locals:{
        edit: result})
end

#   Creates a bid on a specific advert and redirects back to te previus page
#
#   @params [String] quantity, The value of the bid
#
#   @see Model#bid
post("/bid") do
    bid(session[:user], session[:view_post], params["quantity"])
    redirect back
end

#   Displays an error message
#
get("/error") do
    slim(:error)
end

#   Destroys the current session and redirects back to te previus page
#
post("/logout") do 
    session.destroy
    redirect back
end

#   Switches the current user create/loggin values and redirects back to te previus page
#
post("/loggin_create_switch") do
    if session[:keyword_switch] == nil
        session[:keyword_switch] = "create"
    else
        session[:keyword_switch] = nil
    end

    redirect back
end

#   Delete a row from a database table 
#
#   @params [String] table, The name of a table
#   @params [String] field, The name of a field
#   @params [String] item, An item
#
#   @see Model#delete
post("/delete") do
    item = params["item"]
    delete(params["table"], params["field"], item)
    if "user" == params["delete"] 
        var = call_db_table("adverts")
        var.reverse.each do |element|
            if element != 0
                if element["AdUsername"] == session[:user]
                    delete("adverts", "AdUsername", session[:user])
                end
            end 
        end     
        session[:user] = nil   
        session[:logged_in] = false
    end
    redirect back
end
