require 'test_helper'

class ServerTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    File.open('hr-preview-fast.mp4', 'w') {|f| f.write "hello" }
  end

  def teardown
    FileUtils.rm_f 'hr-preview-fast.mp4'
  end

  def test_video_upload_to_mongo
    post '/videos', :video_path => 'hr-preview-fast.mp4'
    assert_equal last_response.status, 201
    assert !last_response.body.nil?
  end

  def test_missing_video_file_upload_to_mongo
    post '/videos', :video_path => 'nonesuch.mp4'
    assert_equal last_response.status, 404
  end

  def test_nil_upload_to_mongo
    post '/videos'
    assert_equal last_response.status, 401
  end

  def test_video_stream
    test_file = File.open('hr-preview-fast.mp4')
    post '/videos', :video_path => test_file.path
    id = last_response.body.match(/'(.*?)'/).captures.last

    get "/videos/#{id}-512.mp4"
    assert_equal "video/mp4", last_response.headers['Content-Type']
    assert_equal test_file.size, last_response.headers['Content-Length'].to_i, "Expected Content Length to be #{test_file.size} was #{last_response.headers['Content-Length']}"
    assert last_response.ok?
  end
end
