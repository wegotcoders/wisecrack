require 'test_helper'

describe Wisecrack::Video do
  describe 'class methods' do
    describe '.create(video_path)' do
      describe 'when request is succesful' do
        before do
          Wisecrack.config(:development) do |config|
            config.base_host_url = 'http://localhost:9292'
          end

          VCR.insert_cassette('wisecrack_video_201')

          @video_id = Wisecrack::Video.create('test/fixtures/mock_upload_file.mp4')
          @cassette = YAML.load_file('test/cassettes/wisecrack_video_201.yml')
        end

        after do
          VCR.eject_cassette
        end

        it 'creates a new video resource in gridfs' do
          response_code = @cassette["http_interactions"].first["response"]["status"]["code"].to_i
          response_code.must_equal(201)
        end

        it 'returns the mongo id of the newly created video resource' do
          id_in_response = JSON.parse(@cassette["http_interactions"].first["response"]["body"]["string"])["video_id"]
          @video_id.must_equal(id_in_response)
        end
      end

      describe 'when request is unsuccessful' do
        before do
          Wisecrack.config(:development) do |config|
            config.base_host_url = 'http://localhost:9292'
          end

          VCR.insert_cassette('test/cassettes/wisecrack_video_404')
        end

        after do
          VCR.eject_cassette
        end

        it 'raises an UploadError' do
          expect { Wisecrack::Video.create('file/that/does/not/exist.mp4') }.must_raise(Wisecrack::Video::UploadError)
        end
      end
    end
  end
end
