require 'resque'
require 'text_extractor'


class TextExtractionJob
  attr_reader :params
  @queue = :default

  def self.perform(params)
    url = params['callback']
    response = self.new(params).call

    Resque.enqueue(EnsureDeleteJob, params['tempfilename'])
    Resque.enqueue(CallbackJob, url, response)
  end

  def initialize(params)
    @params = params
  end

  def call
    {
      filename: params['filename'],
      uuid: params['uuid'],
      content: text
    }
  end

  def text
    TextExtractor.new(File.join('temp', @params['tempfilename'])).call
  end
end
