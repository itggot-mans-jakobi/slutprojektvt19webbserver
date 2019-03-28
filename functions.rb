def call_db(table)
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

    return db.execute("SELECT * FROM (?)", table)
end