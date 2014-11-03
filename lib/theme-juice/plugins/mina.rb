module ThemeJuice
    module Plugins
        class Mina

            ###
            # Setup
            ###
            def self.setup
                unless system "mina setup"
                    ::ThemeJuice::error "Failed to initiate Mina. Be sure to run this command from your project root."
                end
            end

            ###
            # Deploy
            ###
            def self.deploy
                unless system "mina deploy"
                    ::ThemeJuice::error "Failed to initiate Mina. Be sure to run this command from your project root."
                end
            end
        end
    end
end
