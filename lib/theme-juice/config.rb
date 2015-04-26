# encoding: UTF-8

module ThemeJuice
  module Config
    @env      = Env
    @io       = IO
    @project  = Project
    @util     = Util.new

    def install
      config.fetch("commands", {}).fetch("install").each { |cmd| run "#{cmd}" }
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
