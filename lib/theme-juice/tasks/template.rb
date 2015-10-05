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
        install_template
      end

      private

      def clone_template
        @io.log "Cloning template"
        @util.inside @project.location do
          @util.run "git clone --depth 1 #{@project.template} .", {
            :verbose => @env.verbose, :capture => @env.quiet }
        end
      end

      def install_template
        @io.log "Running template installation"
        @config.command :install
      end
    end
  end
end
