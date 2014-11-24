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
            #
            # Prepare server for deployment
            #
            # @return {Void}
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
            #
            # Deploys the current version to the server
            #
            # @return {Void}
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
            # Rollback
            #
            # Rollback to previous release
            #
            # @return {Void}
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
            #
            # @param {String} action
            #   Push or pull database
            #
            # @return {Void}
            ###
            desc "db ACTION", "Database migration, push or pull"
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
            # Environment migration
            #
            # @param {String} action
            #   Push or pull environment file for stage
            #
            # @return {Void}
            ###
            desc "env ACTION", "Environment migration, push or pull"
            def env(action)
                if action == "push" || action == "pull"
                    if system "mina #{options[:env]} env:#{action}"
                        ::ThemeJuice::success "Environment migration successful!"
                    else
                        ::ThemeJuice::error "Failed to migrate environment."
                    end
                else
                    ::ThemeJuice::error "Unknown command `env:#{action}` for environment migration. It's either push or pull."
                end
            end

            ###
            # Uploads migration
            #
            # @param {String} action
            #   Push or pull contents of uploads directory
            #
            # @return {Void}
            ###
            desc "uploads ACTION", "Uploads migration, push or pull"
            def uploads(action)
                if action == "push" || action == "pull"
                    if system "mina #{options[:env]} uploads:#{action}"
                        ::ThemeJuice::success "Uploads migration successful!"
                    else
                        ::ThemeJuice::error "Failed to migrate uploads."
                    end
                else
                    ::ThemeJuice::error "Unknown command `uploads:#{action}` for uploads migration. It's either push or pull."
                end
            end

            ###
            # Plugins migration
            #
            # @param {String} action
            #   Push or pull contents of plugins directory
            #
            # @return {Void}
            ###
            desc "plugins ACTION", "Plugins migration, push or pull"
            def plugins(action)
                if action == "push" || action == "pull"
                    if system "mina #{options[:env]} plugins:#{action}"
                        ::ThemeJuice::success "Plugins migration successful!"
                    else
                        ::ThemeJuice::error "Failed migrate plugins."
                    end
                else
                    ::ThemeJuice::error "Unknown command `plugins:#{action}` for plugins migration. It's either push or pull."
                end
            end
        end
    end
end
