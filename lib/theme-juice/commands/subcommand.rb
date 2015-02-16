# encoding: UTF-8

module ThemeJuice
    class Command::Subcommand < ::ThemeJuice::Command

        #
        # @param {Hash} opts
        #
        # @return {Void}
        #
        def initialize(opts = {})
            super

            ::ThemeJuice::Service::Config.new.subcommand @opts[:subcommand], @opts[:commands]
        end
    end
end
