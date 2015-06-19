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
          Dir["**/*.rb"].each do |path|
            parsed = RuboCop::ProcessedSource.new(File.read(path), path)

            rubocop_team.inspect_file(parsed).each do |violation|
              unless exclude?(path)
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
      end

      private

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
