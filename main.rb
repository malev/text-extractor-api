$:.unshift(File.expand_path('config/', File.dirname(__FILE__)))

require "boot"
require "json"
require "sinatra/base"
require "sinatra/reloader" if development?
require "text_extractor_job"
require "text_extractor"


class ExtractorAPI < Sinatra::Base
  def valid_request?
    params['file'] && params['callback']
  end

  def enqueue
    encoding = params["encoding"]
    callback = params["callback"]
    filename = params["file"][:filename]
    tempfilename = store_temp_file
    Resque.enqueue(TextExtractionJob, tempfilename, filename, callback, encoding)
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
      enqueue
      {
        status: 'ok',
        text: 'empty'
      }.to_json
    else
      response.status = 400 # Bad Request
      { status: 'error', errors: message(params)}.to_json
    end
  end
end

ExtractorAPI.run!
