# encoding: UTF-8

module ThemeJuice
  module Config
    @env     = Env
    @io      = IO
    @project = Project
    @util    = Util.new

    def method_missing(method, *args, &block)
      @project.location ||= Dir.pwd

      begin
        config.fetch("commands", {})
          .fetch("#{method}") { @io.error("Command '#{method}' not found in config") }
          .each { |cmd| run format_command(cmd, *args) }
      rescue ::NoMethodError => err
        @io.error "Config file is invalid" do
          puts err
        end
      end
    end

    private

    def run(command)
      @util.inside @project.location do
        @util.run command, :verbose => @env.verbose
      end
    end

    def format_command(cmd, args = [])

      if multi_arg_regex =~ cmd
        cmd.gsub! multi_arg_regex, args.join(" ")
      else
        args.to_enum.with_index(1).each do |arg, i|
          cmd.gsub! single_arg_regex(i), arg
        end
      end

      cmd
    end

    def config
      begin
        YAML.load_file Dir["#{@project.location}/*"].select { |f| config_regex =~ File.basename(f) }.last ||
          @io.error("Config file not found in '#{@project.location}'")
      rescue ::Psych::SyntaxError => err
        @io.error "Config file is invalid" do
          puts err
        end
      end
    end

    def config_regex
      %r{^(((\.)?(tj)|((J|j)uicefile))(.y(a)?ml)?$)}
    end

    def multi_arg_regex
      %r{(%args%)|(%arguments%)}
    end

    def single_arg_regex(i)
      %r{(%arg#{i}%)|(%argument#{i}%)}
    end

    extend self
  end
end
