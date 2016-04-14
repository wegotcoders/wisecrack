require File.expand_path '../spec_helper.rb', __FILE__

describe Wisecrack::VideosClient do
  before do
    Wisecrack.config(:development) do |config|
      config.base_host_url = 'http://localhost:9292'
    end
  end

  describe '#stream_url' do
    it 'returns url for streaming file at given encoding and given bit rate' do
      url = described_class.stream_url(
        mongo_grid_fs_id: 'mock_grid_fs_id',
        bit_rate: 256,
        video_encoding: 'mp4'
      )

      expect(url).to eq('http://localhost:9292/videos/mock_grid_fs_id-256.mp4')
    end
  end

  describe '#create' do
    context 'file to be uploaded does not exist' do
      it 'returns a 404' do
        VCR.use_cassette 'create_video_404' do
          described_class.create(
            "#{Sinatra::Application.root}/spec/fixtures/does_not_exixt.mp4"
          )
        end

        cassette = YAML.load_file(
          "#{Sinatra::Application.root}/spec/vcr_cassettes/create_video_404.yml"
        )

        response_code = cassette['http_interactions']
          .first['response']['status']['code']

        expect(response_code).to eq(404)
      end
    end

    context 'file uploads to mongo gridfs successfully' do
      it 'returns a 201' do
        VCR.use_cassette 'create_video_201' do
          described_class.create(
            "#{Sinatra::Application.root}/spec/fixtures/mp4_example.mp4"
          )
        end

        cassette = YAML.load_file(
          "#{Sinatra::Application.root}/spec/vcr_cassettes/create_video_201.yml"
        )

        video_mongo_id = JSON.parse(cassette['http_interactions']
          .first['response']['body']['string'])['video_id']

        File.open(
          "#{Sinatra::Application.root}/spec/fixtures/video_mongo_id.txt",
          'w'
          ) do |file|
          file.write("#{video_mongo_id}")
        end

        response_code = cassette['http_interactions']
          .first['response']['status']['code']

        expect(response_code).to eq(201)
      end
    end
  end

  describe '#update' do
    context 'upload file does not exist' do
      it 'returns a 404' do
        video_mongo_id = File.read(
          "#{Sinatra::Application.root}/spec/fixtures/video_mongo_id.txt"
        )

        VCR.use_cassette 'update_video_404' do
          described_class.update(
            "#{Sinatra::Application.root}/spec/fixtures/does_not_exist.mp4",
            video_mongo_id
          )
        end

        cassette = YAML.load_file(
          "#{Sinatra::Application.root}/spec/vcr_cassettes/update_video_404.yml"
        )

        response_code = cassette['http_interactions']
          .first['response']['status']['code']

        expect(response_code).to eq(404)
      end
    end

    context 'file uploads to mongo gridfs successfully' do
      it 'returns a 201' do
        video_mongo_id = File.read(
          "#{Sinatra::Application.root}/spec/fixtures/video_mongo_id.txt"
        )

        VCR.use_cassette 'update_video_201' do
          described_class.update(
            "#{Sinatra::Application.root}/spec/fixtures/mp4_example.mp4",
            video_mongo_id
          )
        end

        cassette = YAML.load_file(
          "#{Sinatra::Application.root}/spec/vcr_cassettes/update_video_201.yml"
        )

        response_code = cassette['http_interactions']
          .first['response']['status']['code']

        expect(response_code).to eq(201)
      end
    end
  end
end
