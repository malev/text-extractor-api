APP_ENV = ENV["APP_ENV"] ||= "development" unless defined?(APP_ENV)
APP_ROOT = File.expand_path("../..", __FILE__).gsub(/releases\/[0-9]+/, "current") + "/" unless defined?(APP_ROOT)
$:.unshift(File.expand_path('../lib/', File.dirname(__FILE__)))

require "yaml"
require "logger"
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

resque_config = YAML.load_file(File.join(APP_ROOT, 'config', 'resque.yml'))
Resque.redis = resque_config[APP_ENV]
