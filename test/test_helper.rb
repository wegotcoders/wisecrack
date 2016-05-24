require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'wisecrack'
require 'rack/test'
require 'minitest/autorun'
require 'pry'
