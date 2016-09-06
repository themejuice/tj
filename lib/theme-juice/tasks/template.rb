# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Template < Task

      def initialize(opts = {})
        super
      end

      def execute
        return unless @project.template

        clone_template

        if @config.exist?
          render_template_config_erb
          install_template
        end
      end

      private

      def clone_template
        @io.log "Cloning template"
        @util.inside @project.location do
          @util.run [], { :verbose => @env.verbose,
            :capture => @env.quiet } do |cmds|
            if @project.template_revision
              cmds << "git clone '#{@project.template}' --depth 1 --branch '#{@project.template_revision}' --single-branch ."
            else
              cmds << "git clone '#{@project.template}' --depth 1 ."
            end
          end
        end
      end

      def render_template_config_erb
        @io.log "Rendering template config ERB"
        save_template_config ERB.new(File.read(@config.path)).result(
          @project.to_h.merge(@env.to_h).to_ostruct.instance_eval { binding }
        )
      end

      def save_template_config(contents)
        @io.log "Saving rendered template config"
        File.open(@config.path, "w+") { |f| f << contents }
        @config.refresh!
      end

      def install_template
        @io.log "Running template installation"
        @config.command :install
      end
    end
  end
end
