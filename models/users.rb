class Users
    attr_reader :id, :username, :email, :first_name, :last_name, :password, :points

    def initialize(user)
        @id = user[0]
        @username = user[1]
        @email = user[2]
        @first_name = user[3]
        @last_name = user[4]
        @password = user[5]
        @points = Users.points(id)
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

    def self.points(id)
        db = SQLite3::Database.open('db/db.sqlite')
        points = 0
        completed_excercices = db.execute('SELECT excercice_id FROM weekly_schedules WHERE user_id IS ? AND done = ?', [id, "true"])

        completed_excercices.each do |x|
            points += db.execute('SELECT difficulty FROM excercices WHERE id IS ?', x.first).first.first.to_i
        end
        return points
    end

    def self.authenticate(username, password, session)
        db = SQLite3::Database.open('db/db.sqlite')

        # Does the username exist?
        if db.execute('SELECT * FROM users WHERE username IS ?', username) == []
            session[:failed_logon] = "Det finns ingen sådan kombination!"
            return false
        else
            password_encrypted = db.execute('SELECT password FROM users WHERE username IS ?', username).first.first
            password_decrypted = BCrypt::Password.new(password_encrypted)
    
            if password_decrypted == password
                id = db.execute('SELECT id FROM users WHERE username IS ?', username).first.first
                # Admin user?
                admin = db.execute('SELECT admin FROM users WHERE username IS ?', username).first.first
                if admin != nil
                    if admin == "true"
                        session[:admin] = true
                        puts "Admin Logged In"
                    end
                end
                session[:user_id] = id
                session[:username] = username
                session[:email] = db.execute('SELECT email FROM users WHERE id IS ?', id).first.first
                session[:failed_logon] = false
                return true
            else
                session[:failed_logon] = "Det finns ingen sådan kombination!"
                return false
            end
        end
    end

    def self.create(username, mail, fname, lname, password, session, weight_goal, distance, goal, day1, day2, day3, day4, day5, day6, day7, strictness)
        db = SQLite3::Database.open('db/db.sqlite')

        # Check if the username already exist, and the mail
        existing_name = db.execute('SELECT * FROM users WHERE username IS ?', username)
        existing_email = db.execute('SELECT * FROM users WHERE email IS ?', mail)
        
        if existing_name == [] && existing_email == []
            if distance == "false"
                distance = 0.5
            end
            sets_and_reps = db.execute('SELECT sets, reps FROM goals WHERE id IS ?', goal).first
            db.execute('INSERT INTO users (username, email, first_name, last_name, password, points, weight_goal, distance, sets, reps) VALUES (?,?,?,?,?,?,?,?,?,?)', [username, mail, fname, lname, password, 0, weight_goal, distance.to_f, sets_and_reps[0], sets_and_reps[1]])

            # Log all the answers
            unless day1
                day1 = "false"
            end
            unless day2
                day2 = "false"
            end
            unless day3
                day3 = "false"
            end
            unless day4
                day4 = "false"
            end
            unless day5
                day5 = "false"
            end
            unless day6
                day6 = "false"
            end
            unless day7
                day7 = "false"
            end

            db.execute('INSERT INTO qna (goal, strictness, monday, tuesday, wednesday, thursday, friday, saturday, sunday, weight_goal, distance, user_id) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)', [goal,strictness,day1,day2,day3,day4,day5,day6,day7,weight_goal,distance,get_id_from_username(username)])
            
            session[:user_id] = get_id_from_username(username)
            session[:username] = username
            session[:email] = mail
            return true
        else
            return false
        end        
    end

    def self.get_id_from_username(username)
        db = SQLite3::Database.open('db/db.sqlite')
        id = db.execute('SELECT id FROM users WHERE username IS ?', username).first.first.to_i
        return id
    end

end