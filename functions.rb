require "bcrypt"

enable :sessions   

#hämta allt från ett specificerat table
def call_db(table)
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

    return db.execute("SELECT * FROM #{table}")
end

#test om lösenord stämmer
def password_test(username, password)
    if password != ""    
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true
        result_password = db.execute("SELECT Password FROM users WHERE Username = #{username}")
        p result_password

        if BCrypt::Password.new(result_password[0]["password"]) == password
            status = true
        else 
            status = false
        end
    else 
        status = false
    end
    return status
end

def user_create(username, password)
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    hashat_password = BCrypt::Password.create(password)

    if username != db.execute("SELECT Username FROM users WHERE Username=#{username}")
        db.execute("INSERT INTO users (Username, Password) VALUES (#{username},#{hashat_password})")
        # ^^ fungerar inte ¨
        
        session[:logged_in] = true
        session[:user] = username
    end
end