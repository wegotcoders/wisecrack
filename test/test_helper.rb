$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'wisecrack'
require 'rack/test'
require 'minitest/autorun'
require 'webmock'
require 'minitest-vcr'
require 'pry'

VCR.configure do |c|
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
end

MinitestVcr::Spec.configure!
