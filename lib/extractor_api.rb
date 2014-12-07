$:.unshift(File.expand_path('config/', File.dirname(__FILE__)))

require "json"
require "sinatra/base"
require "sinatra/reloader"
require "sinatra/config_file"
require "text_extractor"


class ExtractorAPI < Sinatra::Base
  register Sinatra::ConfigFile
  config_file File.expand_path("../../config/config.yml", __FILE__)

  set :logging, true
  set :public_folder, File.join(APP_ROOT, 'static')
  set :views, File.join(APP_ROOT, 'views')

  configure :development do
    register Sinatra::Reloader
  end

  attr_reader :errors

  post "/v1/convert" do
    content_type :json
    @errors = {}

    if valid_request?
      {
        status: 'scheduled',
        filename: params[:file][:filename],
        text: TextExtractor.new(tempfile_path).call
      }.to_json
    else
      response.status = 400 # Bad Request
      { status: 'error', errors: errors}.to_json
    end
  end

  def valid_request?
    this = self
    valid?(:file_size, settings.error_messages['file_size']) { this.valid_file_size? } &&
    valid?(:missing_file, settings.error_messages['missing_file']) { this.file_param_present? } &&
    valid?(:server_busy, settings.error_messages['server_busy']) { this.server_available? }
  end

  def valid_server_status?
    if Dir["temp/*"].reduce(0) { |size, file| size + File.size(file) } <= settings.max_server_space
      true
    else
      errors[:server_busy] = settings.error_messages.server_busy
      false
    end
  end

  def server_available?
    Dir["temp/*"].reduce(0) { |size, file| size + File.size(file) } <= settings.max_server_space
  end

  def valid_file_size?
    request.env['CONTENT_LENGTH'].to_i < settings.max_file_size
  end

  def file_param_present?
    params.has_key?('file')
  end

  def valid?(message_key, message, &block)
    if yield
      true
    else
      errors[message_key] = message
      false
    end
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
