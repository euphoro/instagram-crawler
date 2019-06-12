module InstagramCrawler
  module Parser
    class StoriesJson < Base
      attr_reader :page_info, :user_id

      def initialize(user_id)
        @user_id   = user_id
      end

      def parsing
        url           = stories_src_url(user_id)
        html          = get_json(url)
        json          = JSON.parse(html)
        items         = json["data"]["reels_media"][0]["items"]
        @stories_srcs = items.map {
          |item| OpenStruct.new(
            story_id: item["id"],
            taken_at_timestamp: item["taken_at_timestamp"],
            src: item["video_resources"][1]["src"]
          )
        }

        download_stories()
      end

      private

      def download_stories
        @stories_srcs.each do |story_src|
          Logger.info "========STORY========".light_blue
          time = parse_to_date(story_src["taken_at_timestamp"])
          name = time + "_" + story_src["story_id"]
          url = story_src["src"]
          output(time, url)
          File.download(url, 'story', name)
        end
      end

      def get_json(url)
        http = HTTP.cookies(sessionid: ENV["sessionid"])
        res = Config.proxyname ?
          http.via(Config.proxyname, Config.port).get(url) : http.get(url)
        raise Errors::HttpError, "#{res.code} #{res.reason}" if res.code != 200
        res.to_s
      end

      def stories_src_url(user_id)
        "https://www.instagram.com/graphql/query/?query_hash=cda12de4f7fd3719c0569ce03589f4c4&variables=%7B%22reel_ids%22%3A%5B%22#{user_id}%22%5D%2C%22tag_names%22%3A%5B%5D%2C%22location_ids%22%3A%5B%5D%2C%22highlight_reel_ids%22%3A%5B%5D%2C%22precomposed_overlay%22%3Afalse%2C%22show_story_viewer_list%22%3Atrue%2C%22story_viewer_fetch_count%22%3A50%2C%22story_viewer_cursor%22%3A%22%22%2C%22stories_video_dash_manifest%22%3Afalse%7D"
      end
    end
  end
end
