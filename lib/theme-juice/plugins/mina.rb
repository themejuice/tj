module ThemeJuice
    module Plugins
        class Mina < ::Thor
            namespace :server

            include ::Thor::Actions

            def self.banner(task, namespace = true, subcommand = false)
                "#{basename} #{task.formatted_usage(self, true, subcommand)}"
            end

            class_option :env, :default => "staging", :desc => "Environment", :aliases => "-e"

            ###
            # Setup
            ###
            desc "setup", "Prepare server for deployment"
            def setup
                ::ThemeJuice::warning "Setting up server for deployment..."

                if system "mina #{options[:env]} setup"
                    ::ThemeJuice::success "Setup successful!"
                else
                    ::ThemeJuice::error "Failed to run deployment setup."
                end
            end

            ###
            # Deploy
            ###
            desc "deploy", "Deploys the current version to the server"
            def deploy
                ::ThemeJuice::warning "Deploying to server..."

                if system "mina #{options[:env]} deploy"
                    ::ThemeJuice::success "Deployment successful!"
                else
                    ::ThemeJuice::error "Failed to run deployment."
                end
            end

            ###
            # Deploy
            ###
            desc "rollback", "Rollback to previous release"
            def rollback
                ::ThemeJuice::warning "Deploying to server..."

                if system "mina #{options[:env]} rollback"
                    ::ThemeJuice::success "Rollback successful!"
                else
                    ::ThemeJuice::error "Failed to run rollback."
                end
            end

            ###
            # Database migration
            ###
            desc "db ACTION", "Database migration"
            def db(action)
                if action == "push" || action == "pull"
                    if system "mina #{options[:env]} db:#{action}"
                        ::ThemeJuice::success "Database migration successful!"
                    else
                        ::ThemeJuice::error "Failed migrate database."
                    end
                else
                    ::ThemeJuice::error "Unknown command `db:#{action}` for database migration. It's either push or pull."
                end
            end

            ###
            # Database migration
            ###
            desc "uploads ACTION", "Uploads migration"
            def uploads(action)
                if action == "push" || action == "pull"
                    if system "mina #{options[:env]} uploads:#{action}"
                        ::ThemeJuice::success "Uploads migration successful!"
                    else
                        ::ThemeJuice::error "Failed migrate uploads."
                    end
                else
                    ::ThemeJuice::error "Unknown command `uploads:#{action}` for uploads migration. It's either push or pull."
                end
            end
        end
    end
end
