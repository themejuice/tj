# encoding: UTF-8

module ThemeJuice
  module Tasks
    class SyncedFolder < Entry

      def initialize(opts = {})
        super

        @file = "#{@env.vm_path}/Customfile"
        @name = "synced folder"
        @id   = "SF"
      end

      def execute
        create_entry_file
        create_entry do
%Q{
config.vm.synced_folder '#{@project.location}', '/srv/www/tj-#{@project.name}', mount_options: ['dmode=777','fmode=777']
}
        end
      end

      def unexecute
        remove_entry
      end
    end
  end
end
