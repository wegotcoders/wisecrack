require 'test_helper'

class ServerTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.touch 'hr-preview.mp4'
  end

  def teardown
    FileUtils.rm_f 'hr-preview.mp4'
  end

  def test_video_upload_to_mongo
    post '/videos', :video_path => 'hr-preview.mp4'
    assert_equal last_response.status, 201
    assert !last_response.body.nil?
  end

  def test_missing_video_upload_to_mongo
    post '/videos', :video_path => 'nonesuch.mp4'
    assert_equal last_response.status, 404
  end

  def test_video_stream
    test_file = File.open('hr-preview.mp4')
    post '/videos', :video_path => test_file.path
    id = last_response.body.match(/'(.*?)'/).captures.last

    get "/videos/#{id}", :file_extension => 'mp4', :chunk_factor => 10
    assert_equal last_response.headers['Content-Type'], "video/mp4"
    assert_equal last_response.headers['Content-Length'].to_i, test_file.size, "Expected Content Length to be #{test_file.size} was #{last_response.headers['Content-Length']}"
    assert last_response.ok?
  end
end
