# encoding: UTF-8

module ThemeJuice
    class Command::Delete < ::ThemeJuice::Command

        #
        # @param {Hash} opts
        #
        # @return {Void}
        #
        def initialize(opts = {})
            super

            ::ThemeJuice::Service::DeleteSite.new(@opts).delete
        end
    end
end
