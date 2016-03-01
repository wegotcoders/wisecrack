require 'sinatra'
require 'sinatra/streaming'
require 'mongo'
require 'pry'

set :client, Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'videos')

post '/video' do
  video = File.open(params[:video_path])

  video_id = settings.client.database.fs.upload_from_stream('video.mp4', video, { chunk_size: 10240000 })
  video.close

  # file = Mongo::Grid::File.new(video.read, :filename => 'video.mp4')
  # video_id = settings.client.database.fs(:fs_name => 'videos').insert_one(file)

  content_type :json
  [200, {}, { video_id: video_id} ]
end

get '/video/:id' do
  content_type 'video/mp4'

  begin
    fs_bucket = settings.client.database.fs(:fs_name => 'fs')
    file = Tempfile.new('video')
    fs_bucket.download_to_stream(BSON::ObjectId(params[:id]), file)
  rescue Mongo::Error::UnexpectedChunkLength => e
    puts e.message
  rescue Mongo::Error::ClosedStream => e
    puts e.message
  end

  stream do |out|
    unless out.closed?
      begin
        fs_bucket.open_download_stream(BSON::ObjectId(params[:id])) do |video_stream|
          video_stream.each do |chunk|
            out << chunk
          end
          out.flush
        end
      rescue Mongo::Error::UnexpectedChunkLength => e
        puts e.message
        out.close
      rescue Mongo::Error::ClosedStream => e
        puts e.message
        out.close
      rescue IOError => e
        puts e.message
        out.close
      end
    end
  end
end
