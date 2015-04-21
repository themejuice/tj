# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Theme < Task

      def initialize(opts = {})
        super
      end

      def execute
        if @project.theme
          clone_theme
          install_theme
        end
      end

      private

      def clone_theme
        @interact.log "Cloning theme"
        @util.inside @project.location do
          @util.run "git clone --depth 1 #{@project.theme} .", :verbose => @env.verbose
        end
      end

      def install_theme
        @interact.log "Running theme install"
        @config.install
      end
    end
  end
end
