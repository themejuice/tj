# encoding: UTF-8

module ThemeJuice
    class Service::ConfigFile < ::ThemeJuice::Service

        #
        # @param {Hash} opts
        #
        def initialize(opts = {})
            super
        end

        #
        # Run installation from config
        #
        # @return {Void}
        #
        def install
            use_config

            @config["commands"]["install"].each do |command|
                run ["cd #{@config_path}", command], false
            end
        end

        #
        # Run subcommand from config
        #
        # @param {String} subcommand
        # @param {String} command
        #
        # @return {Void}
        #
        def subcommand(subcommand, command)
            use_config

            if @config["commands"][subcommand]
                run ["#{@config["commands"][subcommand]} #{command}"], false
            else
                ::ThemeJuice::Interaction.error "Unable to find '#{subcommand}' command in '#{@config_path}/tj.yml'. Aborting mission."
            end
        end
    end
end
