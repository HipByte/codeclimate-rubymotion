require 'rubocop'
require 'cc/rubymotion_cops'
require 'json'

module CC
  module Engine
    class Rubymotion
      def initialize(directory: , io: , engine_config: )
        @directory = directory
        @engine_config = engine_config
        @io = io
      end

      def run
        Dir.chdir(@directory) do
          files_to_analyze.each do |path|
            parsed = RuboCop::ProcessedSource.new(File.read(path), path)

            rubocop_team.inspect_file(parsed).each do |violation|
              json = {
                type: "Issue",
                check_name: "RubyMotion/#{violation.cop_name}",
                description: violation.message,
                categories: ["Style"],
                remediation_points: 50_000,
                location: {
                  path: path,
                  lines: {
                    begin: violation.location.first_line,
                    end: violation.location.last_line,
                  }
                }
              }.to_json

              @io.print "#{json}\0"
            end
          end
        end
      end

      private

      def files_to_analyze
        if @engine_config["include_paths"]
          build_files_with_inclusions(@engine_config["include_paths"])
        else
          build_files_with_exclusions(@engine_config["exclude_paths"] || [])
        end
      end

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

      def exclude?(path)
        exclusions = @engine_config["exclude_paths"] || []
        exclusions.include?(path)
      end

      def rubocop_team
        RuboCop::Cop::Team.new(CC::RubymotionCops.all, rubocop_config)
      end

      def rubocop_config
        @rubocop_config ||= RuboCop::Config.new({}, "")
      end

    end
  end
end
