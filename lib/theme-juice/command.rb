# encoding: UTF-8

module ThemeJuice
    class Command
        include ::Thor::Actions
        include ::Thor::Shell

        #
        # @param {Hash} opts
        #
        # @return {Void}
        #
        def initialize(opts = {})
            @environment = ::ThemeJuice::Environment
            @interaction = ::ThemeJuice::Interaction
            @opts        = opts
        end
    end
end
