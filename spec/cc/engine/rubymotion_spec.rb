require "spec_helper"
require "cc/engine/rubymotion"
require "tmpdir"

module CC::Engine
  describe Rubymotion do
    before { @code = Dir.mktmpdir }

      describe "#DeallocMustCallSuper" do
        it "finds an error" do
          create_source_file("foo.rb", <<-EORUBY)

            class DoTheWrongThing
              def dealloc
                "cool"
              end
            end
          EORUBY

          output = run_engine
          assert includes_check?(output, "RubyMotion/Rubymotion/DeallocMustCallSuper")
        end

        it "does not find an error" do
          create_source_file("foo.rb", <<-EORUBY)

            class DoTheRightThing
              def dealloc
                "cool"
                super
              end
            end
          EORUBY

          output = run_engine
          assert !includes_check?(output, "RubyMotion/Rubymotion/DeallocMustCallSuper")
        end
      end

      describe "DoNotCallRetaincount" do
        it "finds an error" do
          create_source_file("foo.rb", <<-EORUBY)
            def coolMethod(obj)
              obj.retainCount # don't do this!
            end
          EORUBY

          output = run_engine
          assert includes_check?(output, "RubyMotion/Rubymotion/DoNotCallRetaincount")
        end

        it "finds an error with send" do
          create_source_file("foo.rb", <<-EORUBY)
            def coolerMethod(obj)
              obj.send(:retainCount) # don't do this either!
            end
          EORUBY

          output = run_engine
          assert includes_check?(output, "RubyMotion/Rubymotion/DoNotCallRetaincount")
        end
      end

      describe "InitMustReturnSelf" do
        it "finds an error with no return" do
          create_source_file("foo.rb", <<-EORUBY)
             def init
               1+1
             end
          EORUBY

          output = run_engine
          assert includes_check?(output, "RubyMotion/Rubymotion/InitMustReturnSelf")
        end

        it "finds no error with implicit return" do
          create_source_file("foo.rb", <<-EORUBY)
             def init
               1+1
               self
             end
          EORUBY

          output = run_engine
          assert !includes_check?(output, "Rubymotion/InitMustReturnSelf")
        end

        it "finds no error with explicit return" do
          create_source_file("foo.rb", <<-EORUBY)
             def init
               1+1
               return self
             end
          EORUBY

          output = run_engine
          assert !includes_check?(output, "Rubymotion/InitMustReturnSelf")
        end
      end

      describe 'with exclude paths config' do
        it "doesn't run an analysis on a file listed in excluded paths" do
          file_source = <<-EORUBY
            def init
              1+1
            end
          EORUBY

          create_source_file('foo.rb', file_source)
          create_source_file('bar.rb', file_source)

          output = run_engine({"exclude_paths" => %w(bar.rb)})
          assert !includes_file?(output, 'bar.rb')
        end

      end

      describe 'with include paths config' do
        it "runs an analysis only on files listed in included paths" do
          file_source = <<-EORUBY
            def init
              1+1
            end
          EORUBY

          create_source_file('foo.rb', file_source)
          create_source_file('bar.rb', file_source)

          output = run_engine({"include_paths" => %w(foo.rb)})
          assert !includes_file?(output, 'bar.rb')
        end
      end

    def includes_check?(output, cop_name)
      issues = parse_output(output)

      !!issues.detect { |i| i["check_name"] =~ /#{cop_name}$/ }
    end

    def includes_file?(output, file_name)
      issues = parse_output(output)

      !!issues.detect { |i| i["check_name"] =~ /#{file_name}$/ }
    end

    def parse_output(output)
      output.split("\0").map { |x| JSON.parse(x) }
    end

    def create_source_file(path, content)
      File.write(File.join(@code, path), content)
    end

    def with_engine_config(hash)
      Tempfile.open("config.json") do |fh|
        fh.puts(hash.to_json)
        fh.rewind

        return yield(fh.path)
      end
    end

    def run_engine(config = {})
      io = StringIO.new
      rubymotion = Rubymotion.new(directory: @code, engine_config: config, io: io)
      rubymotion.run

      io.string
    end
  end
end
