$:.unshift(File.expand_path('config/', File.dirname(__FILE__)))

require "json"
require "sinatra/base"
require "sinatra/reloader"
require "sinatra/config_file"
require "file_process_job"
require "text_extractor"


class ExtractorAPI < Sinatra::Base
  register Sinatra::ConfigFile
  config_file File.expand_path("../../config/config.yml", __FILE__)

  set :logging, true

  configure :development do
    register Sinatra::Reloader
  end

  attr_reader :errors

  post "/v1/convert-now" do
    content_type :json
    @errors = {}

    if valid_now_request?
      {
        status: 'scheduled',
        filename: params["file"][:filename],
        text: TextExtractor.new(tempfile_path).call
      }.to_json
    else
      response.status = 400 # Bad Request
      { status: 'error', errors: errors}.to_json
    end
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

  def valid_now_request?
    valid_now_size? && valid_file? && valid_callback? && valid_server_status?
  end

  def valid_request?
    valid_size? && valid_file? && valid_callback? && valid_server_status?
  end

  def valid_server_status?
    if Dir["temp/*"].reduce(0) { |size, file| size + File.size(file) } <= settings.max_server_space
      true
    else
      errors[:server_busy] = settings.error_messages.server_busy
      false
    end
  end

  def valid_now_size?
    if request.env['CONTENT_LENGTH'].to_i <= settings.max_now_file_size
      true
    else
      errors[:file_size] = settings.error_messages.file_now_size
      false
    end
  end

  def valid_size?
    if request.env['CONTENT_LENGTH'].to_i <= settings.max_file_size
      true
    else
      errors[:file_size] = settings.error_messages.file_size
      false
    end
  end

  def valid_file?
    if params.has_key?('file')
      true
    else
      errors[:missing_file] = settings.error_messages.missing_file
      false
    end
  end

  def valid_callback?
    if params.has_key?('callback')
      true
    else
      errors[:missing_callback] = settings.error_messages.missing_callback
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
end
