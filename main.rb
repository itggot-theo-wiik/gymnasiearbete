class Main < Sinatra::Base
    get '/' do
        "It's alive, /register"
    end

    get '/register' do
        "hello"
        erb :new
    end

end