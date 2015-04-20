# encoding: UTF-8

module ThemeJuice
  module Config
    @env      = Env
    @interact = Interact
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
      YAML.load_file Dir["#{@project.location}/*"].select { |f| %r{^(\.)?(tj.y(a)?ml)} =~ File.basename(f) }.last ||
        @interact.error("Config file not found")
    end

    extend self
  end
end
