require 'json'
require 'sinatra'

set :port, 3000
Rack::Utils.key_space_limit = 123456789

post '/callback' do
  content_type :json
  request.body.rewind
  puts JSON.parse request.body.read
  { status: 'ok'}.to_json
end
