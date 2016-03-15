module Wisecrack
  def self.config(env = :development)
    if block_given? && ENV['RACK_ENV'].to_sym == env.to_sym
      yield Sinatra::Application.settings
    else
      Sinatra::Application.settings
    end
  end
end
