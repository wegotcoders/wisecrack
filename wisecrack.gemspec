# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wisecrack/version'

Gem::Specification.new do |spec|
  spec.name          = "wisecrack"
  spec.version       = Wisecrack::VERSION
  spec.authors       = ["Dan Garland", "Alfred Oliver Willder"]
  spec.email         = ["dan@dangarland.co.uk", "alfred.oliver.willder@gmail.com"]

  spec.summary       = %q{A simple video streaming server for HTML5}
  spec.description   = %q{A sinatra app that streams data out of Mongo GridFS}
  spec.homepage      = "https://github.com/wegotcoders/wisecrack"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra", "~> 1.4"
  spec.add_dependency "sinatra-contrib"
  spec.add_dependency "mongo", ">= 2.2"
  spec.add_dependency "json"
  spec.add_dependency "thin"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
end
