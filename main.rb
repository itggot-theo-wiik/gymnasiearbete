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

    get '/chart' do
        slim :chart
    end

end