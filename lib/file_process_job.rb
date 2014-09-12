require 'resque'
require 'text_extractor'


class FileProcessJob
  @queue = :default

  def self.perform(params)
    url = params['callback']
    begin
      response = {
        filename: params['filename'],
        uuid: params['uuid'],
        content: TextExtractor.new(File.join('temp', params['tempfilename'])).call
      }
      raise "holaaaa"
      self.new(params).call
      Resque.enqueue(CallbackJob, url, response)
    ensure
      Resque.enqueue(EnsureDeleteJob, params['tempfilename'])
    end
  end
end
