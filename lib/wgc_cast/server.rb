require 'sinatra'
require 'sinatra/streaming'
require 'mongo'

configure :development do
  set :client, Mongo::Client.new(['127.0.0.1:27017'], :database => 'wgc_elearning_development')
end

configure :production do
  set :client, Mongo::Client.new(['127.0.0.1:27017'], :database => 'wgc_elearning_production')
end

post '/videos' do
  if File.exists? params[:video_path]
    video = File.new(params[:video_path])
    video_id = settings
      .client
      .database
      .fs(bucket_name: 'videos')
      .upload_from_stream('video.mp4', video)

    video.close

    content_type :json
    [201, {}, { video_id: video_id} ]
  else
    404
  end
end

get '/videos/:id' do
  fs_bucket = settings.client.database.fs(:fs_name => 'videos')
  content_length = fs_bucket.find(_id: BSON::ObjectId(params[:id])).first[:length]

  headers \
    'Content-Length' => content_length,
    'Content-Type' => "video/#{params[:file_extension]}"

  @chunk_count = 0
  @bigger_chunk = ""

  stream do |out|
    unless out.closed?
      begin
        fs_bucket.open_download_stream(BSON::ObjectId(params[:id])) do |video_stream|
          video_stream.each do |chunk|
            @chunk_count += 1
            @bigger_chunk << chunk
            if @chunk_count % params[:chunk_factor].to_i == 0 || video_stream.file_info.chunk_size > chunk.size
              out << @bigger_chunk.to_s
              @bigger_chunk = ""
            end
          end
        end
      end
    end
  end
end
