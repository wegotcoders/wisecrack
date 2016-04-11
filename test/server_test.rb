require 'test_helper'
require 'pry'

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

  def test_video_update_to_mongo
    post '/videos', :video_path => 'hr-preview-fast.mp4'

    post(
      '/videos_update',
      :video_path => 'hr-preview-fast.mp4',
      :previous_id => BSON::ObjectId(JSON.parse(last_response.body)["video_id"])
    )

    assert_equal last_response.status, 201
    assert !last_response.body.nil?
  end

  def test_missing_video_file_update_to_mongo
    post '/videos_update', :video_path => 'nonesuch.mp4'
    assert_equal last_response.status, 404
  end

  def test_nil_update_to_mongo
    post '/videos_update'
    assert_equal last_response.status, 401
  end

  def test_video_stream
    test_file = File.open('hr-preview-fast.mp4')
    post '/videos', :video_path => test_file.path
    id = JSON(last_response.body)["video_id"]

    get "/videos/#{id}-512.mp4"
    assert_equal 200, last_response.status
    assert_equal "video/mp4", last_response.headers['Content-Type']
    assert_equal test_file.size, last_response.headers['Content-Length'].to_i, "Expected Content Length to be #{test_file.size} was #{last_response.headers['Content-Length']}"
    assert last_response.ok?
  end
end
