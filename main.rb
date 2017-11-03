class Main < Sinatra::Base
    get '/' do
        erb :home
    end

    get '/register' do
        erb :new
    end

    get '/chart' do
        erb :chart
    end

end