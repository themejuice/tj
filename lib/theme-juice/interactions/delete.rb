# encoding: UTF-8

module ThemeJuice
  module Interaction::Delete

    @environment = ::ThemeJuice::Environment
    @interaction = ::ThemeJuice::Interaction

    class << self

      #
      # Get needed site options
      #
      # @param {Hash} opts
      #
      # @return {Hash}
      #
      def get_project_options(opts = {})
        @opts = opts

        @opts[:project_name]         ||= get_project_name
        @opts[:project_dev_location] ||= get_project_dev_location

        @opts
      end

      private

      #
      # Site name
      #
      # @return {String}
      #
      def get_project_name
        name = @interaction.choose "Which project would you like to delete?", :red, ::ThemeJuice::Service::List.new.get_sites
      end

      #
      # Site development location
      #
      # @return {String}
      #
      def get_project_dev_location
        dev_location = File.expand_path("#{@environment.vvv_path}/www/tj-#{@opts[:project_name]}")
      end
    end
  end
end
