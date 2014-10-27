module Tinder
    module Tasks
        class Capistrano < ::Thor
            namespace :deploy

            include Thor::Actions

            def self.banner(task, namespace = true, subcommand = false)
                "#{basename} #{task.formatted_usage(self, true, subcommand)}"
            end

            desc "install", "Install Capistrano"
            def install
                ::Tinder::warning "Installing..."
            end
        end
    end
end
