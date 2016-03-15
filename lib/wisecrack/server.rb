require 'sinatra'
require 'sinatra/streaming'
require 'mongo'
require 'json'

configure :development do
  set :client, Mongo::Client.new(['127.0.0.1:27017'], :database => 'wisecrack_development')
end

configure :production do
  set :client, Mongo::Client.new(['127.0.0.1:27017'], :database => 'wisecrack_production')
end

post '/videos' do
  if params[:video_path].nil?
    401
  elsif File.exists? params[:video_path]
    video = File.new(params[:video_path])
    content_type :json
    status 201
    { video_id: bucket.upload_from_stream(File.basename(video), video).to_s }.to_json
  else
    404
  end
end

# Streams a video out of grid fs
# e.g. GET /videos/56e81c9fd855de1e383ce055-512.mp4
#
get '/videos/:id-:bitrate.:file_extension' do |id, bitrate, file_extension|
  video_id = BSON::ObjectId(id)

  headers \
    'Content-Length' => bucket.find(_id: video_id).first[:length].to_s,
    'Content-Type' => "video/#{file_extension}"

  stream do |out|
    unless out.closed?
      # begin
        bucket.open_download_stream(video_id) do |video_stream|
          video_stream.each do |chunk|
            out << chunk
            normal_bit_rate = chunk.size / 1024 + 1
            sleep normal_bit_rate / bitrate.to_f
          end
        end
      # rescue Ex
      # end
    end
  end
end

private
def bucket
  @bucket ||= settings.client.database.fs(bucket_name: 'videos')
end