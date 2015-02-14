# encoding: UTF-8

module ThemeJuice
    class Interaction::DeleteSiteOptions

        #
        # Set up interactions and environment
        #
        # @return {Void}
        #
        def initialize
            @environment = ::ThemeJuice::Environment
            @interaction = ::ThemeJuice::Interaction
        end

        #
        # Get needed site options
        #
        # @param {Hash} opts
        #
        # @return {Hash}
        #
        def get_site_options(opts = {})
            @opts = opts

            required_opts = [
                :site_name,
                :site_dev_location
            ]

            required_opts.each do |opt|
                @opts[opt] = self.send "get_#{opt}" unless @opts[opt]
            end

            @opts
        end

        private

        #
        # Site name
        #
        # @return {String}
        #
        def get_site_name
            name = @interaction.choose "Which site would you like to delete?", :red, ::ThemeJuice::Service::ListSites.new.get_sites
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
