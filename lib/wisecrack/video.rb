module Wisecrack::Video
  class UploadException < Exception; end

  class << self
    def stream_url(mongo_grid_fs_id:, bit_rate: 256, video_encoding: 'mp4')
      "#{streaming_host}/#{mongo_grid_fs_id}-#{bit_rate}.#{video_encoding}"
    end

    def create(video_path)
      res = http_post_to_streaming_server(video_path)

      if res.code_type == Net::HTTPCreated
        JSON(res.body)["video_id"]
      else
        raise UploadException.new("Failed to create with video #{video_path}")
      end
    end

    private
    def http_post_to_streaming_server(file_name)
      req = Net::HTTP::Post.new(streaming_host)
      req.set_form_data('video_path' => file_name)

      res = Net::HTTP.start(streaming_host.hostname, streaming_host.port) do |http|
        http.request(req)
      end
    end

    def streaming_host
      URI.parse([Wisecrack.current_config.base_host_url, "videos"].join("/"))
    end
  end
end
