# encoding: UTF-8

module ThemeJuice
  module Tasks
    class SyncedFolder < Task

      def initialize(opts = {})
        super
      end

      def execute
        create_synced_folder unless synced_folder_is_setup?
      end

      def unexecute
        remove_synced_folder
      end

      private

      def custom_file
        File.expand_path "#{@env.vm_path}/Customfile"
      end

      def synced_folder_is_setup?
        File.readlines(custom_file).grep(/(#(#*)? Begin '#{@project.name}' SF)/m).any?
      end

      def create_synced_folder
        @interact.log "Creating synced folder entries"
        @util.append_to_file custom_file, :verbose => @env.verbose do
%Q{# Begin '#{@project.name}' SF
config.vm.synced_folder '#{@project.location}', '/srv/www/tj-#{@project.name}', mount_options: ['dmode=777','fmode=777']
# End '#{@project.name}' SF

}
        end
      end

      def remove_synced_folder
        @interact.log "Removing synced folder entries"
        @util.gsub_file custom_file, /(#(#*)? Begin '#{@project.name}' SF)(.*?)(#(#*)? End '#{@project.name}' SF)\n+/m,
          "", :verbose => @env.verbose
      end
    end
  end
end
