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

            ::ThemeJuice::Service::ConfigFile.new.subcommand
        end
    end
end
