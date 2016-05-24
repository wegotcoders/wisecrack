require 'simplecov'
SimpleCov.start
require 'wisecrack/api'
require 'rack/test'
require 'webmock'
require 'vcr'
require 'rspec'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../lib/wisecrack.rb', __FILE__

set :root, File.join(File.dirname(__FILE__), '../')

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
end
