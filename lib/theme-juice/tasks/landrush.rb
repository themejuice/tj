# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Landrush < Task

      def initialize(opts = {})
        super

        @name = "landrush"
      end

      def execute
        setup_wildcard_subdomains
      end

      def unexecute
        remove_wildcard_subdomains
      end

      private

      def custom_file
        File.expand_path "#{@env.vm_path}/Customfile"
      end

      def wildcard_subdomains_is_setup?
        File.readlines(custom_file).grep(/(#(#*)? Begin '#{@name}')/m).any?
      end

      def setup_wildcard_subdomains
        @interact.log "Creating landrush wildcard subdomains"
        @util.append_to_file custom_file, :verbose => @env.verbose do
%Q{# Begin '#{@name}'
config.landrush.enabled = true
config.landrush.tld = 'dev'
# End '#{@name}'

}
        end
      end

      def remove_wildcard_subdomains
        @interact.log "Removing landrush wildcard subdomains"
        @util.gsub_file custom_file, /(#(#*)? Begin '#{@name}')(.*?)(#(#*)? End '#{@name}')\n+/m,
          "", :verbose => @env.verbose
      end
    end
  end
end
