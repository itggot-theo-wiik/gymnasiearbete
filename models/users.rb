class Users
    def initialize(user)
        @id = user[0]
        @username = user[1]
        @email = user[2]
        @first_name = user[3]
        @last_name = user[4]
        @password = user[5]
        @points = user[6]
    end

    def self.all
        db = SQLite3::Database.open('db/db.sqlite')
        users = db.execute('SELECT * FROM users')
        return users.map { |row| Users.new(row) }
    end

end