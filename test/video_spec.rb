require 'test_helper'

describe Wisecrack::Video do
  describe 'class methods' do
    before do
      Wisecrack.config(:development) do |config|
        config.base_host_url = 'http://localhost:9292'
      end
    end

    describe '.create(video_path)' do
      describe 'when request is succesful' do
        before do
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
          VCR.insert_cassette('test/cassettes/wisecrack_video_404')
        end

        after do
          VCR.eject_cassette
        end

        describe 'the exception raised' do
          it 'is an UploadError' do
            upload_error = assert_raises(Wisecrack::Video::UploadError) do
              Wisecrack::Video.create('file/that/does/not/exist.mp4')
            end
          end

          it 'contains a message for the devleloper' do
            path_that_does_not_exist = 'file/that/does/not/exist.mp4'

            upload_error = assert_raises(Wisecrack::Video::UploadError) do
              Wisecrack::Video.create(path_that_does_not_exist)
            end

            upload_error.message.must_equal "Failed to create with video #{path_that_does_not_exist}"
          end
        end
      end
    end

    describe('.stream_url') do
      it 'returns a correctly formatted url' do
        mock_mongo_grid_fs_id = 'mock_id'
        mock_bit_rate = 999
        mock_file_extension = 'xyz'

        stream_url = Wisecrack::Video.stream_url(mongo_grid_fs_id: mock_mongo_grid_fs_id, bit_rate: mock_bit_rate, video_encoding: mock_file_extension)
        stream_url.must_equal('http://localhost:9292/videos/mock_id-999.xyz')
      end
    end
  end
end
