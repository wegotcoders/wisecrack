ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'wgc_cast'

require 'minitest/autorun'
require 'rack/test'
require 'pry'