# encoding: UTF-8

module ThemeJuice
    class Command::Create < ::ThemeJuice::Command

        #
        # @param {Hash} opts
        #
        # @return {Void}
        #
        def initialize(opts = {})
            super

            ::ThemeJuice::Service::CreateSite.new(@opts).create
        end
    end
end
