module ThemeJuice
    module Plugins
        class Mina

            ###
            # Setup
            ###
            def self.setup
                ::ThemeJuice::warning "Setting up server for deployment..."

                if system "mina setup"
                    ::ThemeJuice::success "Setup successful!"
                else
                    ::ThemeJuice::error "Failed to run deployment setup."
                end
            end

            ###
            # Deploy
            ###
            def self.deploy
                ::ThemeJuice::warning "Deploying to server..."
                
                if system "mina deploy"
                    ::ThemeJuice::success "Deployment successful!"
                else
                    ::ThemeJuice::error "Failed to run deployment setup."
                end
            end
        end
    end
end
