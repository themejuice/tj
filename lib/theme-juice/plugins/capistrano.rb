module ThemeJuice
    module Plugins
        class Capistrano < ::Thor
            namespace :deploy

            include Thor::Actions

            def self.banner(task, namespace = true, subcommand = false)
                "#{basename} #{task.formatted_usage(self, true, subcommand)}"
            end
        end
    end
end
