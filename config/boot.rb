require 'logger'
require "rubygems" unless defined?(Gem)
Bundler.require(:default)

Resque.logger = Logger.new('logs/extractor.log')
Resque.logger.level = Logger::DEBUG
