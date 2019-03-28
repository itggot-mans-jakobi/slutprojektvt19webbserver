require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"
require_relative "function.rb"
# require_relative ""

enable :sessions    

get("/") do
    slim(:index)
end