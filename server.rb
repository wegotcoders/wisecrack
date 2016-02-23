require 'sinatra'
require "sinatra/streaming"
require 'mongoid/grid_fs'

configure do
  Mongoid.load!('config/mongoid.yml', :development)
end

post '/video' do
  grid_fs = Mongoid::GridFs
  f = grid_fs.put(File.open(params[:video_path]))
  content_type :json
  [200, {}, { video_id: f.id} ]
end

get '/video/:id' do
  grid_fs = Mongoid::GridFs
  g = grid_fs.get(params[:id])
  # content_type 'video/mp4'
  # g.data
  stream do |out|
    g.each do |chunk|
      out.puts(chunk.length)
      out.flush
    end
  end
end


