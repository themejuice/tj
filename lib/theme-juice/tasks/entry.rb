# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Entry < Task
      attr_accessor :entry_file
      attr_accessor :entry_name
      attr_accessor :entry_id

      def initialize(opts = {})
        super
      end

      private

      def entry_file_is_setup?
        File.exist? @entry_file
      end

      def create_entry_file
        unless entry_file_is_setup?
          @io.log "Creating #{@entry_name} file"
          @util.create_file @entry_file, nil, :verbose => @env.verbose
        end
      end

      def entry_is_setup?
        File.readlines(@entry_file).grep(/(#(#*)? Begin '#{@project.name}' #{@entry_id})/m).any?
      end

      def create_entry(&block)
        unless entry_is_setup?
          @io.log "Creating #{@entry_name} entry"
          @util.append_to_file @entry_file, :verbose => @env.verbose do
%Q{# Begin '#{@project.name}' #{@entry_id}
#{yield}
# End '#{@project.name}' #{@entry_id}

}
          end
        end
      end

      def remove_entry
        @io.log "Removing #{@entry_name} entry"
        @util.gsub_file @entry_file, /(#(#*)? Begin '#{@project.name}' #{@entry_id})(.*?)(#(#*)? End '#{@project.name}' #{@entry_id})\n+/m,
          "", :verbose => @env.verbose
      end
    end
  end
end
