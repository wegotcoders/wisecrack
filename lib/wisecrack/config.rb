module Wisecrack
  class Configuration
    attr_accessor :base_host_url
  end

  class << self
    attr_accessor :env

    def config(env = :development)
      self.env = env.to_sym
      if block_given?
        yield configurations[self.env] = Configuration.new
      else
        configurations
      end
    end

    def configurations
      @configuratations ||= {}
    end

    def current_config
      configurations[self.env]
    end
  end
end
