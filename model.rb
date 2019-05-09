require "bcrypt"
require "sqlite3"

enable :sessions   

module MyModule

    def call_db()
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true 
        return db
    end

    #hämta allt från ett specificerat table
    def call_db_table(table)
        db = call_db()

        return db.execute("SELECT * FROM #{table}")
    end

    def call_db_table_specifik(table, item)
        db = call_db()

        return db.execute("SELECT AdId, AdUsername, Adtext, AdPicture, AdKeyword FROM adverts WHERE AdId = #{item}")
    end

    #test om lösenord stämmer
    def password_test(username, password)
        if password != ""    
            db = call_db()
            result_password = db.execute("SELECT Password FROM users WHERE Username = ?", username)
            # p result_password.first["password"]

            if BCrypt::Password.new(result_password.first["Password"]) == password
                status = true
                session[:logged_in] = true
            else 
                status = false
                session[:logged_in] = false
            end
        else 
            status = false
        end
        return status
    end

    def user_create(username, password)
        # p username
        # p password
        db = call_db()
        hashat_password = BCrypt::Password.create(password)

        if username != db.execute("SELECT (Username) FROM users WHERE Username = ?", username)
            result = db.execute("INSERT INTO users (Username, Password) VALUES (?, ?)", username, hashat_password)        
            
            session[:logged_in] = true
            session[:user] = username
        end
    end

    def ad_create(adusername, adtext, adpicture, adkeyword)
        db = call_db()
        db.execute("INSERT INTO adverts (AdUsername, AdText, AdPicture, AdKeyword) VALUES (?,?,?,?)", adusername, adtext, adpicture, adkeyword)
    end

    def get_userid_from_name(username)
        db = call_db()

        id = db.execute("SELECT (UserId) FROM users WHERE Username = ?", username).first["UserId"]
    
        return id
    end

    def get_name_from_userid(userid)
        db = call_db()

        id = db.execute("SELECT (Username) FROM users WHERE UserId = ?", userid).first["Username"]
    
        return id
    end

    def bid(username, idad, bid)
        db = call_db()
        id = get_userid_from_name(username)
        db.execute("INSERT INTO auctions (IdUsername, IdAd, bid) VALUES (?,?,?)", id, idad, bid)
    end

end