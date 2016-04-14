module Wisecrack
  module VideosClient
    class << self
      def stream_url(mongo_grid_fs_id:, bit_rate: 256, video_encoding: 'mp4')
        "#{streaming_host}/#{mongo_grid_fs_id}-#{bit_rate}.#{video_encoding}"
      end

      def create(video_path)
        req = Net::HTTP::Post.new(streaming_host)
        req.set_form_data('video_path' => video_path)

        res = Net::HTTP.start(
          streaming_host.hostname,
          streaming_host.port
        ) { |http| http.request(req) }
      end

      def update(video_path, video_mongo_id)
        req = Net::HTTP::Post.new(update_url)

        req.set_form_data(
          'video_path' => video_path,
          'previous_id' => video_mongo_id
        )

        res = Net::HTTP.start(
          streaming_host.hostname,
          streaming_host.port
        ) { |http| http.request(req) }
      end

      private
      def streaming_host
        URI.parse(
          [Wisecrack.current_config.base_host_url, 'videos'].join('/')
        )
      end

      def update_url
        URI.parse(
          [Wisecrack.current_config.base_host_url, 'videos_update'].join('/')
        )
      end
    end
  end
end
