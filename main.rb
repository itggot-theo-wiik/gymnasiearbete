class Main < Sinatra::Base

    enable :sessions

    get '/' do
        if session[:user_id]
            @quote = Quote.random()
            @user = Users.one(session[:user_id].to_i)
            @schedule = Schedule.get2(session[:user_id])
        end

        slim :home
    end

    get '/login' do
        slim :login
    end

    post '/login' do
        username = params['login_username']
        password = params['login_password']
        if Users.authenticate(username, password, session)
            redirect '/'
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
        @goals = Schedule.get_goals()
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
        weight_goal = params['weight_goal'].to_f

        # Create a new profile
        if Users.create(username, mail, fname, lname, password, session, weight_goal)
            # Create custom schedual
            user_id = Users.get_id_from_username(username)
            Schedule.create(day1,day2,day3,day4,day5,day6,day7,strictness.to_i,goals.to_i,user_id)

            redirect '/my-profile'
        else
            redirect '/register'
        end
    end

    get '/schedule' do
        if session[:user_id]
            # @schedule = Schedule.get(session[:user_id])
            @schedule = Schedule.get2(session[:user_id])
            slim :schedule
        else
            redirect '/login'
        end
    end

    post '/schedule/done' do
        id = params['id']
        feedback = params['feedback']
        puts feedback
        Schedule.check(id, session)
        redirect '/schedule'
    end

    get '/user' do
        @users = Users.all
        slim :list
    end

    get '/user/:id' do
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

            @percentage_reached = Weight.percentage_of_goal_reached(session[:user_id], session)
            
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

    post '/add-excercice' do
        day = params['day']
        excercice_name = params['new_excercice']
        user_id = session[:user_id].to_i
        Schedule.add_custom(day, excercice_name, user_id)
        redirect '/schedule'
    end

    get '/about' do
        slim :about
    end

    get '/run' do
        slim :run
    end

    get '/learn/sets_and_reps' do
        slim :'learn/sets_and_reps'
    end
end