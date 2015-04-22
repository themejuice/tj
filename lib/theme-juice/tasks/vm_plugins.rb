# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VMPlugins < Task

      def initialize(opts = {})
        super
      end

      def execute
        install_vagrant_plugin "vagrant-hostsupdater", "0.0.11"
        install_vagrant_plugin "vagrant-triggers", "0.5.0"
        install_vagrant_plugin "landrush", "0.18.0"
      end

      private

      def install_vagrant_plugin(plugin, version)
        @interact.log "Installing #{plugin}"
        @util.run "vagrant plugin install #{plugin} --plugin-version #{version}", {
          :verbose => @env.verbose, :pretend => @env.dryrun }
      end
    end
  end
end
