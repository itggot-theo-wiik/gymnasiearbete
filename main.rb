class Main < Sinatra::Base
    get '/' do
        slim :home
    end

    get '/register' do
        slim :register
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