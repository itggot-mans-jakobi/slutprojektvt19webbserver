require "bcrypt"
require "sqlite3"

# MyModule
# @since 0.6.0
module MyModule

    # Loads the database
    #
    # @return [Hash]
    def call_db()
        db = SQLite3::Database.new("db/database.db")
        db.results_as_hash = true 
        return db
    end

    # Finds a specific database table
    #
    # @param [String] table Name of table
    #
    # @return [Hash]
    def call_db_table(table)
        db = call_db()

        return db.execute("SELECT * FROM #{table}")
    end

    # Finds "AdId", "AdUsername", "Adtext", "AdPicture", "AdKeyword" in a database table named adverts with a specific "AdId"
    #
    # @param [String] table Name of table
    # @param [String] item Name of item
    #
    # @return [Hash]
    #   *"AdId" [String] the id
    #   *"AdUsername" [String] the username
    #   *"Adtext" [String] the text
    #   *"AdPicture" [String] the picture
    def call_db_table_specifik(table, item)
        db = call_db()

        return db.execute("SELECT AdId, AdUsername, Adtext, AdPicture, AdKeyword FROM adverts WHERE AdId = #{item}")
    end

    # Attempts to compare the new password and the stored password
    #
    # @param [String] username username
    # @param [String] password password
    #
    # @return [false] if the passwords do not match
    # @return [true] if the passwords do match
    def password_test(username, password)
        db = call_db()
        result_password = db.execute("SELECT Password FROM users WHERE Username = ?", username)
        status = false
        if result_password != []
            if BCrypt::Password.new(result_password.first["Password"]) == password
                status = true
            end
        end
        return status
    end

    # Attempts to create a new user
    #
    # @param [String] username username
    # @param [String] password password
    #
    # @return [false] if the username exist
    # @return [true] if the user was created
    def user_create(username, password)
        db = call_db()
        hashat_password = BCrypt::Password.create(password)
        status = false
        if user_exist(username) == false
            result = db.execute("INSERT INTO users (Username, Password) VALUES (?, ?)", username, hashat_password)        
            status = true
        end
        return status
    end

    # Attempts to locate a user
    #
    # @param [String] username username
    #
    # @return [false] if the user does not exist
    # @return [true] if the user exist
    def user_exist(username)
        db = call_db()
        status = false
        usernameFromDb = db.execute("SELECT (Username) FROM users WHERE Username = ?", username)
        if usernameFromDb != []
            if username == usernameFromDb.first["Username"]
                status = true
            end
        end
        return status
    end

    # Creates an advert
    #
    # @param [String] adusername username
    # @param [String] adtext the text
    # @param [String] adpicture a picture
    # @param [String] adkeyword a keyword ("sell"/"buy")
    def ad_create(adusername, adtext, adpicture, adkeyword)
        db = call_db()
        db.execute("INSERT INTO adverts (AdUsername, AdText, AdPicture, AdKeyword) VALUES (?,?,?,?)", adusername, adtext, adpicture, adkeyword)
    end

    # Updates an advert
    #
    # @param [String] adusername username
    # @param [String] adtext the text
    # @param [String] adpicture a picture
    def ad_update(adusername, adtext, adpicture)
        db = call_db()
        adid = get_userid_from_name(adusername)
        db.execute("UPDATE adverts SET AdText = ? WHERE AdId = ?", adtext, adid)
        db.execute("UPDATE adverts SET adpicture = ? WHERE AdId = ?", adpicture, adid)
    end
    
    # Attempts to locate a userid by its username
    #
    # @param [String] username username
    #
    # @return [String] id, userid
    def get_userid_from_name(username)
        db = call_db()
        id = db.execute("SELECT (UserId) FROM users WHERE Username = ?", username).first["UserId"]
    
        return id
    end

    # Attempts to locate a username by its userid
    #
    # @param [String] userid userid
    #
    # @return [false] username
    def get_name_from_userid(userid)
        db = call_db()
        username = db.execute("SELECT (Username) FROM users WHERE UserId = ?", userid).first["Username"]
        return username
    end
    
    # Creates a bid
    #
    # @param [String] username username
    # @param [String] idad id of the ad
    # @param [String] bid biding amount
    def bid(username, idad, bid)
        db = call_db()
        id = get_userid_from_name(username)
        db.execute("INSERT INTO auctions (IdUsername, IdAd, bid) VALUES (?,?,?)", id, idad, bid)
    end

    # Deletes a row from a database table 
    #
    # @param [String] table a table
    # @param [String] field a field
    # @param [String] item the item to identify a row    def delete(table, param, item)
    def delete(table, field, item)
        db = call_db()
        db.execute("DELETE FROM #{table} WHERE #{field} = ?", item)
    end

end