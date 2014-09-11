require 'httparty'
require 'json'


class CallbackJob
  attr_reader :url, :response
  @queue = :default

  def self.perform(url, response)
    self.new(url, response).call
  end

  def initialize(url, response)
    @url = url
    @response = response
  end

  def call
    HTTParty.post(url, {:body => response.to_json})
  end
end
