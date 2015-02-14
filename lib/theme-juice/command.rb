# encoding: UTF-8

module ThemeJuice
    class Command
        include ::Thor::Actions
        include ::Thor::Shell

        def initialize(opts = {})
            @environment = ::ThemeJuice::Environment
            @interaction = ::ThemeJuice::Interaction
            @opts        = opts
        end
    end
end
