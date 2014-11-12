module ThemeJuice
    module Plugins
        class Mina

            ###
            # Setup
            ###
            def self.setup(env)
                ::ThemeJuice::warning "Setting up server for deployment..."

                if system "mina setup on=#{env}"
                    ::ThemeJuice::success "Setup successful!"
                else
                    ::ThemeJuice::error "Failed to run deployment setup."
                end
            end

            ###
            # Deploy
            ###
            def self.deploy(env)
                ::ThemeJuice::warning "Deploying to server..."

                if system "mina deploy on=#{env}"
                    ::ThemeJuice::success "Deployment successful!"
                else
                    ::ThemeJuice::error "Failed to run deployment setup."
                end
            end

            ###
            # Deploy
            ###
            def self.rollback(env)
                ::ThemeJuice::warning "Deploying to server..."

                if system "mina rollback on=#{env}"
                    ::ThemeJuice::success "Deployment successful!"
                else
                    ::ThemeJuice::error "Failed to run deployment setup."
                end
            end
        end
    end
end
