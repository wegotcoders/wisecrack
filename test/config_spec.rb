require 'test_helper'

describe Wisecrack::Configuration do
  describe 'class methods' do
    describe '.current_config' do
      describe 'when block given' do
        it 'sets the base host url for the given environment' do
          Wisecrack.config(:mock_env) do |config|
            config.base_host_url = 'http://mock_host_url'
          end

          configurations = Wisecrack.send(:configurations)
          mock_env_url = configurations[:mock_env].base_host_url
          mock_env_url.must_equal('http://mock_host_url')
        end
      end

      describe 'when no block given' do
        before do
          Wisecrack.config(:mock_env) do |config|
            config.base_host_url = 'http://mock_host_url'
          end
        end

        it 'returns the object stored in @configurations' do
          configurations = Wisecrack.config(:mock_env)
          mock_env_url = configurations[:mock_env].base_host_url
          mock_env_url.must_equal('http://mock_host_url')
        end
      end
    end
  end
end
