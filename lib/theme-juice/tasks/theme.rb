# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Theme < Task

      def initialize(opts = {})
        super
      end

      def execute
        clone_theme
      end

      def unexecute
      end

      private

      def clone_theme
        @interact.log "Setting up theme"
        # @util.run [
        #   "cd #{@project.location} ",
        #   "git clone --depth 1 #{@project.theme} .",
        # ].join("&&"), :verbose => @env.verbose
      end
    end
  end
end
