require 'json'
require 'sinatra'

set :port, 3000

post '/callback' do
  content_type :json
  p params
  p request
  { status: 'ok'}.to_json
end
