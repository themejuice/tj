# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VMPlugins < Task

      def initialize(opts = {})
        super
      end

      def execute
        install_vagrant_plugin "vagrant-triggers", "0.5.0"
        install_vagrant_plugin "vagrant-hostsupdater", "0.0.11"
        install_vagrant_plugin "landrush", "1.0.0" unless @env.no_landrush
      end

      private

      def vagrant_plugin_is_installed?(plugin)
        `vagrant plugin list`.include? plugin
      end

      def install_vagrant_plugin(plugin, version)
        return if vagrant_plugin_is_installed? plugin

        @io.log "Installing #{plugin}"
        @util.run "vagrant plugin install #{plugin} --plugin-version #{version}", {
          :verbose => @env.verbose, :capture => @env.quiet }
      end
    end
  end
end
