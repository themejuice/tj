# encoding: UTF-8

module ThemeJuice
  module Config
    @env      = Env
    @io       = IO
    @project  = Project
    @util     = Util.new

    def method_missing(method, *args, &block)
      @project.location ||= Dir.pwd

      config.fetch("commands", {})
        .fetch(method.to_s) { @io.error("Command '#{method}' not found in config") }
        .each { |cmd| run "#{cmd} #{args.join(" ") unless args.empty?}" }
    end

    private

    def run(command)
      @util.inside @project.location do
        @util.run command, :verbose => @env.verbose
      end
    end

    def config
      YAML.load_file Dir["#{@project.location}/*"].select { |f| regex =~ File.basename(f) }.last ||
        @io.error("Config file not found in '#{@project.location}'")
    end

    def regex
      %r{^((\.)?(tj.y(a)?ml)|((J|j)uicefile))}
    end

    extend self
  end
end
