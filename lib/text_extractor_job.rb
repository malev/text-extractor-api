require 'resque'
require 'text_extractor'


class TextExtractionJob
  @queue = :default

  def self.perform(params)
    self.new(params).work
  end

  def initialize(params)
    @params = params
  end

  def work
    text = TextExtractor.new(File.join('temp', @params['tempfilename'])).call
  end
end
