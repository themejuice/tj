# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Landrush < Task

      def initialize(opts = {})
        super
      end

      def execute
        setup_landrush unless landrush_is_setup?
      end

      def unexecute
        remove_landrush
      end

      private

      def custom_file
        File.expand_path "#{@env.vm_path}/Customfile"
      end

      def landrush_is_setup?
        File.readlines(custom_file).grep(/(#(#*)? Begin 'landrush')/m).any?
      end

      def setup_landrush
        @interact.log "Creating landrush config"
        @util.append_to_file custom_file, { :verbose => @env.verbose, :pretend => @env.dryrun } do
%Q{# Begin 'landrush'
config.landrush.enabled = true
config.landrush.tld = 'dev'
# End 'landrush'

}
        end
      end

      def remove_landrush
        @interact.log "Removing landrush config"
        @util.gsub_file custom_file, /(#(#*)? Begin 'landrush')(.*?)(#(#*)? End 'landrush')\n+/m,
          "", { :verbose => @env.verbose, :pretend => @env.dryrun }
      end
    end
  end
end
