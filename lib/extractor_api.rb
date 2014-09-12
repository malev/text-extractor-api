$:.unshift(File.expand_path('config/', File.dirname(__FILE__)))

require "json"
require "sinatra/base"
require "sinatra/reloader"
require "file_process_job"
require "text_extractor"


class ExtractorAPI < Sinatra::Base
  attr_reader :errors

  set :logging, true

  configure :development do
    register Sinatra::Reloader
  end

  def valid_request?
    valid_size? && valid_file? && valid_callback?
  end

  def valid_size?
    if request.env['CONTENT_LENGTH'].to_i <= 5_120_000
      true
    else
      errors[:request_size] = "The Request is too big. Maybe you are trying to process a file bigger that 5Mb."
      false
    end
  end

  def valid_file?
    if params.has_key?('file')
      true
    else
      errors[:missing_file] = "You need to upload a file to convert."
      false
    end
  end

  def valid_callback?
    if params.has_key?('callback')
      true
    else
      errors[:missing_file] = "You need a callback parameter."
      false
    end
  end

  def enqueue
    Resque.enqueue(FileProcessJob, {
      tempfilename: store_temp_file,
      filename: params["file"][:filename],
      callback: params["callback"],
      encoding: params.fetch('encoding')
    })
    uuid
  end

  def uuid
    @uuid ||= SecureRandom.uuid
  end

  def store_temp_file
    filename = uuid + '.tmp'
    FileUtils.cp(tempfile_path, File.join('temp', filename))
    filename
  end

  def tempfile_path
    params['file'][:tempfile].path
  end

  post "/v1/convert" do
    content_type :json
    @errors = {}

    if valid_request?
      {
        status: 'scheduled',
        filename: params["file"][:filename],
        uuid: enqueue
      }.to_json
    else
      response.status = 400 # Bad Request
      { status: 'error', errors: errors}.to_json
    end
  end
end
