class Main < Sinatra::Base
    get '/' do
        slim :home
    end

    get '/login' do
        slim :login
    end

    get '/register' do
        slim :register
    end

    post '/register' do
        # db = SQLite3::Database.open('db/db.sqlite')
        username = params['username_account']
        password = params['password']
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
        puts "------------------------------"
        p day1
        p day2
        p day3
        p day4
        p day5
        p day6
        p day7
        p username
        p password
        p mail
        p goals
        p "@@@@@@@@@@@@@@@@@@@@2"
        p strictness
        puts "------------------------------"

        db.execute('INSERT INTO users (username, email, first_name, last_name, password, points) VALUES ("användarnman","email", "första namn", "efternamn", "lösenord", 0)', [username, password, mail])

        redirect :'/register'
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

    get '/weight' do
        slim :weight
    end

    post '/weight' do
        weight = params['new_weight'].to_i
        db = SQLite3::Database.open('db/db.sqlite')
        date = Time.now.strftime("%Y%m%d %H%M")

        db.execute('INSERT INTO weights (kg, date, user_id) VALUES (?,?,?)', [weight, date, 1])
        redirect '/weight'
    end
end