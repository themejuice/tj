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
            def get_site_options(opts = {})
                @opts = opts

                @opts[:site_name]         ||= get_site_name
                @opts[:site_dev_location] ||= get_site_dev_location

                @opts
            end

            private

            #
            # Site name
            #
            # @return {String}
            #
            def get_site_name
                name = @interaction.choose "Which site would you like to delete?", :red, ::ThemeJuice::Service::List.new.get_sites
            end

            #
            # Site development location
            #
            # @return {String}
            #
            def get_site_dev_location
                dev_location = File.expand_path("#{@environment.vvv_path}/www/tj-#{@opts[:site_name]}")
            end
        end
    end
end
