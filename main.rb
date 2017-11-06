class Main < Sinatra::Base
    get '/' do
        slim :home
    end

    get '/register' do
        slim :register
    end

    get '/chart' do
        slim :chart
    end

end