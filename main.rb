$:.unshift(File.expand_path('config/', File.dirname(__FILE__)))

require "boot"
require "json"
require "sinatra/base"
require "sinatra/reloader" if development?
require "text_extractor_job"
require "text_extractor"


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
      {
        status: 'ok',
        text: TextExtractor.new(params[:file][:tempfile]).call
      }.to_json
    else
      response.status = 400 # Bad Request
      { status: 'error', message: message(params)}.to_json
    end
  end
end

ExtractorAPI.run!
