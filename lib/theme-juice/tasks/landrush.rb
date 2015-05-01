# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Landrush < Entry

      def initialize(opts = {})
        super

        @entry = {
          :project => "landrush",
          :file    => "#{@env.vm_path}/Customfile",
          :name    => "landrush",
          :id      => "LR"
        }
      end

      def execute
        unless @env.no_landrush
          create_entry_file
          create_entry do
%Q{config.landrush.enabled = true
config.landrush.tld = 'dev'}
          end
        end
      end

      def unexecute
        remove_entry
      end
    end
  end
end
