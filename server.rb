require 'sinatra'
require 'sinatra/streaming'
require 'mongo'
require 'pry'

set :client, Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'elearning')

post '/videos' do
  video = File.open(params[:video_path])

  video_id = settings
    .client
    .database
    .fs(bucket_name: 'videos')
    .upload_from_stream('video.mp4', video)

  video.close

  content_type :json
  [201, {}, { video_id: video_id} ]
end

get '/videos/:id' do
  headers \
    'Content-Length' => '60317938',
    'Content-Type' => "video/#{params[:file_extension]}"
  fs_bucket = settings.client.database.fs(:fs_name => 'videos')

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
