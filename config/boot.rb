APP_ENV = ENV["APP_ENV"] ||= "development" unless defined?(APP_ENV)

require 'logger'
require "rubygems" unless defined?(Gem)
Bundler.require(:default)

LOGGER = Logger.new("logs/extractor_#{APP_ENV}.log")
LOGGER.level = APP_ENV == "development" ? Logger::INFO : Logger::ERROR

Resque.logger = LOGGER
Resque.logger.level = LOGGER.level

module Kernel
  def logger(message, level=:info)
    LOGGER.send(level, message)
  end
end
