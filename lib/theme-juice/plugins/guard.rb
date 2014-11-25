module ThemeJuice
    module Plugins
        class Guard

            ###
            # Runs all default Guard tasks
            #
            # @return {Void}
            ###
            def self.all
                unless system "bundle exec guard -i"
                    ::ThemeJuice::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end

            ###
            # Watch Sass files
            #
            # @return {Void}
            ###
            def self.sass
                unless system "bundle exec guard -i -P compass"
                    ::ThemeJuice::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end

            ###
            # Watch Coffee
            #
            # @return {Void}
            ###
            def self.coffee
                unless system "bundle exec guard -i -P coffeescript"
                    ::ThemeJuice::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end

            ###
            # Watch Haml
            #
            # @return {Void}
            ###
            def self.haml
                unless system "bundle exec guard -i -P haml"
                    ::ThemeJuice::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end

            ###
            # Optimize images
            #
            # @return {Void}
            ###
            def self.optimize
                unless system "bundle exec guard -i -P optimize"
                    ::ThemeJuice::error "Failed to initiate Guard. Be sure to run this command from your project root."
                end
            end
        end
    end
end
