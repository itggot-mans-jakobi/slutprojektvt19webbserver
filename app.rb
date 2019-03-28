require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require_relative "functions.rb"
# require_relative ""

enable :sessions    

get("/") do

    result = call_db("users")
    slim(:index)
end