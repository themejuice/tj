# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Entry < Task
      attr_accessor :file
      attr_accessor :name
      attr_accessor :id

      def initialize(opts = {})
        super
      end

      private

      def entry_file_is_setup?
        File.exist? @file
      end

      def create_entry_file
        unless entry_file_is_setup?
          @io.log "Creating #{@name} file"
          @util.create_file @file, nil, :verbose => @env.verbose
        end
      end

      def entry_is_setup?
        File.readlines(@file).grep(/(#(#*)? Begin '#{@project.name}' #{@id})/m).any?
      end

      def create_entry(&block)
        unless entry_is_setup?
          @io.log "Creating #{@name} entry"
          @util.append_to_file @file, :verbose => @env.verbose do
%Q{# Begin '#{@project.name}' #{@id}
#{yield}
# End '#{@project.name}' #{@id}

}
          end
        end
      end

      def remove_entry
        @io.log "Removing #{@name} entry"
        @util.gsub_file @file, /(#(#*)? Begin '#{@project.name}' #{@id})(.*?)(#(#*)? End '#{@project.name}' #{@id})\n+/m,
          "", :verbose => @env.verbose
      end
    end
  end
end
