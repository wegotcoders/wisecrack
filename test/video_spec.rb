require 'spec_helper'

describe Video do
  let(:video)  { Video.new }
  let(:lesson) { Lesson.make!(:with_video) }
  let(:track)  { lesson.track }

  describe 'class methods' do
    describe 'go_live_with(lesson)' do
      before do
        stub_request(:post, "#{Rails.configuration.video_streaming_url}/videos").
        to_return(:status => 201, :body => %{ { "video_id": "56d9a0a449de7775c570f720" } })

        lesson
      end

      it 'should prompt the streaming server to store a video in mongo gridfs' do
        WebMock.should have_requested(:post, "#{Rails.configuration.video_streaming_url}/videos").with(
          :body => "video_path=#{lesson.video_path_mp4}".gsub(/\//, '%2F')
        )

        expect(lesson.video_mongo_id).to eq('56d9a0a449de7775c570f720')
      end
    end
  end
end
