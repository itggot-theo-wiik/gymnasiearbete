class Main < Sinatra::Base
    get '/' do
        "It's alive, /register"
    end

    get '/register' do
        "hello"
        erb :new
    end

    get '/chart' do
        "this is a chart"
        erb :chart
    end

end