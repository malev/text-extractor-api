$:.unshift(File.expand_path('config/', File.dirname(__FILE__)))

require "json"
require "sinatra/base"
require "sinatra/reloader"
require "text_extractor_job"
require "text_extractor"


class ExtractorAPI < Sinatra::Base
  def valid_request?
    params['file'] && params['callback']
  end

  def enqueue
    Resque.enqueue(TextExtractionJob, {
      tempfilename: store_temp_file,
      filename: params["file"][:filename],
      callback: params["callback"],
      encoding: params.fetch('encoding')
    })
  end

  def message
    errors = {}
    errors['missing_file'] = "You need a file parameter" unless params.has_key?('file')
    errors['missing_callback'] = "You need a callback parameter" unless params.has_key?('callback')
    errors
  end

  def store_temp_file
    filename = SecureRandom.uuid + '.tmp'
    FileUtils.cp(tempfile_path, File.join('temp', filename))
    filename
  end

  def tempfile_path
    params['file'][:tempfile].path
  end

  post "/v1/convert" do
    content_type :json

    if valid_request?
      # enqueue
      {
        status: 'scheduled',
        text: TextExtractor.new(File.join('temp', store_temp_file)).call,
        filename: params["file"][:filename]
      }.to_json
    else
      response.status = 400 # Bad Request
      { status: 'error', errors: message(params)}.to_json
    end
  end
end
