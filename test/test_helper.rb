ENV['RACK_ENV'] = 'test'

require_relative '../server.rb'

require 'minitest/autorun'
require 'rack/test'
require 'pry'