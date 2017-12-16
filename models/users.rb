class Users
    attr_reader :id, :username, :email, :first_name, :last_name, :password, :points

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

    def self.one(id)
        db = SQLite3::Database.open('db/db.sqlite')
        user = db.execute('SELECT * FROM users WHERE id IS ?', id).first
        return Users.new(user)
    end

    def self.create(username, mail, fname, lname, password, session)
        db = SQLite3::Database.open('db/db.sqlite')
        db.execute('INSERT INTO users (username, email, first_name, last_name, password, points) VALUES (?,?,?,?,?,?)', [username, mail, fname, lname, password, 0])
        session[:user_id] = get_id_from_username(username)
    end

    def self.get_id_from_username(username)
        db = SQLite3::Database.open('db/db.sqlite')
        id = db.execute('SELECT id FROM users WHERE username IS ?', username).first.first.to_i
        return id
    end

end