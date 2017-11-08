class Main < Sinatra::Base
    get '/' do
        slim :home
    end

    get '/register' do
        slim :register
    end

    post '/register' do
        day1 = params['day1']
        day2 = params['day2']
        day3 = params['day3']
        day4 = params['day4']
        day5 = params['day5']
        day6 = params['day6']
        day7 = params['day7']
        puts "------------------------------"
        puts day1
        puts day2
        puts "------------------------------"
        redirect :register
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

    get '/chart' do
        slim :chart
    end

end