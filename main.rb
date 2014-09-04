require 'json'
require 'tempfile'

require "sinatra/base"
require 'resque'

class TextExtractor
  def initialize(option={})
    @options = options
  end

  def call
    filename = ''
    File.open(filename) do |file|
      Docsplit.extract_text(temp.path, output: temp_dir)
    end
  end
end

class TextExtractionJob
  def work

  end
end

class CallbackJob
  def work
  end
end

class ExtractorAPI < Sinatra::Base
  def valid_request?(params)
    params['file'] && params['callback']
  end

  def message(params)
    output = ""
    output << "| You need a file" unless params.has_key?('file')
    output << "| You need a calback url" unless params.has_key?('calback')
    output
  end

  post "/v1/convert" do
    content_type :json

    puts "fsdfsdf"

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
