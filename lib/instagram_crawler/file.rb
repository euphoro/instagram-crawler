module InstagramCrawler
  class File < ::File
    class << self
      def mkdir
        return unless Config.download
        Logger.info "Create directory in #{Config.base_path}\n"
        FileUtils.mkdir_p(Config.base_path) unless Dir.exist?(Config.base_path)
      end

      def download(url, dir_name, file_name)
        return unless Config.download
        binary_data, mime_type = get_binary_data(url)

        puts mime_type

        extname =
          case dir_name
          when "video" then ".mp4"
          else
            ".jpeg"
          end

        dir_path  = "#{Config.base_path}/#{dir_name}"
        FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

        file_path = "#{dir_path}/#{file_name}#{extname}"


        File.open(file_path, 'wb') do |f|
          f.write binary_data
        end
      end

      private

      def get_binary_data(url)
        res = Config.proxyname ?
          HTTP.via(Config.proxyname, Config.port).get(url) : HTTP.get(url)
        raise Errors::HttpError, "#{res.code} #{res.reason}" if res.code != 200
        [res.to_s, res.mime_type]
      end
    end
  end
end
