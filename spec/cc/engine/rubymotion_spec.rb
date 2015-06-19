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

    def includes_check?(output, cop_name)
      issues = output.split("\0").map { |x| JSON.parse(x) }

      !!issues.detect { |i| i["check_name"] =~ /#{cop_name}$/ }
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

    def run_engine(config_path = nil)
      io = StringIO.new
      rubymotion = Rubymotion.new(directory: @code, engine_config: {}, io: io)
      rubymotion.run

      io.string
    end
  end
end
