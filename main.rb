require 'json'
require 'resque'
require "sinatra/base"


class TextExtractionJob
  @queue = :default

  def self.perform(file)
    TextExtractor.new(file).call
  end
end

class ExtractorAPI < Sinatra::Base
  def valid_request?(params)
    params['file'] && params['callback']
  end

  def message(params)
    output = []
    output << "You need a file parameter" unless params.has_key?('file')
    output << "You need a callback parameter" unless params.has_key?('callback')
    output.join('. ')
  end

  post "/v1/convert" do
    content_type :json

    if valid_request?(params)
      # Schedule conversion
      { status: 'ok' }.to_json
    else
      response.status = 400 # Bad Request
      { status: 'error', message: message(params)}.to_json
    end
  end
end

ExtractorAPI.run!
