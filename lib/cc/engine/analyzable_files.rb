module CC
  module Engine
    class AnalyzableFiles
      def initialize(config)
        @config = config
      end

      def all
        @files ||= if @config["include_paths"]
          build_files_with_inclusions(@config["include_paths"])
        else
          build_files_with_exclusions(@config["exclude_paths"] || [])
        end
      end

      private

      def build_files_with_inclusions(inclusions)
        inclusions.map do |include_path|
          if include_path =~ %r{/$}
            Dir.glob("#{include_path}/**/*.rb")
          else
            include_path if include_path =~ /\.rb$/
          end
        end.flatten.compact
      end

      def build_files_with_exclusions(exclusions)
        files = Dir.glob("**/*.rb")
        files.reject { |f| exclusions.include?(f) }
      end
    end
  end
end
