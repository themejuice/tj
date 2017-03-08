# encoding: UTF-8

module ThemeJuice
  module Tasks
    class VMPlugins < Task

      def initialize(opts = {})
        super
      end

      def execute
        install_vagrant_plugin "vagrant-triggers", "0.5.3"
        install_vagrant_plugin "landrush", "1.2.0" unless @env.no_landrush
      end

      private

      def vagrant_plugin_is_installed?(plugin, version)
        plugins = `vagrant plugin list`
        current_version = plugins.match(/#{plugin} \(([[0-9]\.]+)(?:,[^\)]+)?\)/)[1]

        return false if !plugins.include?(plugin) || current_version.nil?

        Gem::Version.new(current_version) >= Gem::Version.new(version)
      end

      def install_vagrant_plugin(plugin, version)
        return if vagrant_plugin_is_installed? plugin, version

        @io.log "Installing #{plugin}"
        @util.run "vagrant plugin install #{plugin} --plugin-version #{version}", {
          :verbose => @env.verbose, :capture => @env.quiet }
      end
    end
  end
end
