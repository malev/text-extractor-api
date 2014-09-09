APP_ENV = ENV["APP_ENV"] ||= "development" unless defined?(APP_ENV)

require 'logger'
require "rubygems" unless defined?(Gem)
Bundler.require(:default)


LOGGER = Logger.new("logs/extractor_#{APP_ENV}.log")
LOGGER.level = Logger::DEBUG

Resque.logger = LOGGER
Resque.logger.level = Logger::DEBUG

module Kernel
  def logger(message, level=:info)
    LOGGER.send(level, message)
  end
end
