# encoding: UTF-8

module ThemeJuice
  module Tasks
    class Entry < Task
      attr_accessor :entry

      def initialize(opts = {})
        super
      end

      private

      def entry_file_is_setup?
        File.exist? @entry.fetch(:file)
      end

      def create_entry_file
        unless entry_file_is_setup?
          @io.log "Creating #{@entry.fetch(:name)} file"
          @util.create_file @entry.fetch(:file), nil, :verbose => @env.verbose
        end
      end

      def entry_is_setup?
        File.readlines(@entry.fetch(:file)).grep(/(#(#*)? Begin '#{@entry.fetch(:project)}' #{@entry.fetch(:id)})/m).any?
      end

      def create_entry(&block)
        unless entry_is_setup?
          @io.log "Creating #{@entry.fetch(:name)} entry"
          @util.append_to_file @entry.fetch(:file), :verbose => @env.verbose do
%Q{# Begin '#{@entry.fetch(:project)}' #{@entry.fetch(:id)}
#{yield}
# End '#{@entry.fetch(:project)}' #{@entry.fetch(:id)}

}
          end
        end
      end

      def remove_entry
        @io.log "Removing #{@entry.fetch(:name)} entry"
        @util.gsub_file @entry.fetch(:file), /(#(#*)? Begin '#{@entry.fetch(:project)}' #{@entry.fetch(:id)})(.*?)(#(#*)? End '#{@entry.fetch(:project)}' #{@entry.fetch(:id)})\n+/m,
          "", :verbose => @env.verbose
      end
    end
  end
end
