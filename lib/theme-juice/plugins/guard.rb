module ThemeJuice
    module Plugins
        class Guard

            ###
            # Watch all
            ###
            def self.all
                unless system "bundle exec guard"
                    ::ThemeJuice::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end

            ###
            # Watch Sass files
            ###
            def self.sass
                unless system "bundle exec guard -P compass"
                    ::ThemeJuice::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end

            ###
            # Watch Coffee
            ###
            def self.coffee
                unless system "bundle exec guard -P coffeescript"
                    ::ThemeJuice::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end

            ###
            # Watch Haml
            ###
            def self.haml
                unless system "bundle exec guard -P haml"
                    ::ThemeJuice::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end

            ###
            # Optimize images
            ###
            def self.optimize
                unless system "bundle exec guard -P optimize"
                    ::ThemeJuice::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end
        end
    end
end
