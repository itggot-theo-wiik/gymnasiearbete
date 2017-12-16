class Main < Sinatra::Base

    enable :sessions

    get '/' do
        if session[:user_id]
            @user = Users.one(session[:user_id].to_i)
        end

        slim :home
    end

    get '/login' do
        slim :login
    end

    post '/login' do
        username = params['login_username']
        password = params['login_password']

        db = SQLite3::Database.open('db/db.sqlite')
        password_encrypted = db.execute('SELECT password FROM users WHERE username IS ?', username).first.first
        password_decrypted = BCrypt::Password.new(password_encrypted)

        if password_decrypted == password
            id = db.execute('SELECT id FROM users WHERE username IS ?', username).first.first
            session[:user_id] = id
            redirect '/my-profile'
        else
            redirect '/login'
        end

    end

    get '/my-profile' do
        if session[:user_id]
            id = session[:user_id]
            @user = Users.one(id)
            slim :'my-profile'
        else
            redirect '/login'
        end
    end

    get '/register' do
        slim :register
    end

    post '/register' do
        db = SQLite3::Database.open('db/db.sqlite')
        username = params['username_account']
        fname = params['fname']
        lname = params['lname']
        password = params['password']
        password = BCrypt::Password.create(password)
        mail = params['mail']
        goals = params['goals']
        strictness = params['strictness']
        day1 = params['day1']
        day2 = params['day2']
        day3 = params['day3']
        day4 = params['day4']
        day5 = params['day5']
        day6 = params['day6']
        day7 = params['day7']

        # Check if the username already exist, and the mail
        # varr = db.execute('SELECT username FROM users WHERE username IS ?', username)

        # Create a new profile
        Users.create(username, mail, fname, lname, password, session)

        # Create custom schedual
        user_id = Users.get_id_from_username(username)
        Schedule.create(day1,day2,day3,day4,day5,day6,day7,strictness.to_i,goals.to_i,user_id)

        redirect :'/my-profile'
    end

    get '/schedule' do
        if session[:user_id]
            @schedule = Schedule.get(session[:user_id])
            p "--------------------"
            p @schedule
            p "--------------------"
            slim :schedule
        else
            redirect '/login'
        end
    end

    get '/users' do
        @users = Users.all
        slim :list
    end

    get '/users/:id' do
        id = params['id'].to_i
        @user = Users.one(id)
        slim :show
    end

    get '/log-out' do
        session.destroy
        redirect '/login'
    end

    get '/weight' do
        if session[:user_id]
            db = SQLite3::Database.open('db/db.sqlite')
            id = session[:user_id]
            x = db.execute('SELECT date FROM weights WHERE user_id IS ?', id)
            y = db.execute('SELECT kg FROM weights WHERE user_id IS ?', id)

            @date_arr = []
            x.each do |z|
                @date_arr << z.first
            end

            @kg_arr = []
            y.each do |z|
                @kg_arr << z.first
            end

            @color = ["#64ffda", "#9effff"]
            
            slim :weight
        else
            redirect '/login'
        end
    end

    post '/weight' do
        weight = params['new_weight'].to_f

        if weight <= 0 || weight > 635
            session[:local] = true
            redirect '/weight'
        else
            session[:local] = false
            if session[:user_id]
                db = SQLite3::Database.open('db/db.sqlite')
                date = Time.now.strftime("%Y-%m-%d %H:%M")
                id = session[:user_id]

                db.execute('INSERT INTO weights (kg, date, user_id) VALUES (?,?,?)', [weight, date, id])
                redirect '/weight'
            else
                redirect '/login'
            end
        end
    end
end