module Wisecrack
  class Configuration
    attr_accessor :base_host_url
  end

  class << self
    def config(env = :development)
      if block_given?
        yield configurations[env] = Configuration.new
      else
        configurations
      end
    end

    def configurations
      @configuratations ||= {}
    end

    def current_config
      configurations[env]
    end

    attr_writer :env

    def env
      (@env || ENV['RACK_ENV'] || :development).to_sym
    end
  end
end