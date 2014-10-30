module ThemeJuice
    module Tasks
        class Composer < ::Thor
            namespace :vendor

            include ::Thor::Actions

            def self.banner(task, namespace = true, subcommand = false)
                "#{basename} #{task.formatted_usage(self, true, subcommand)}"
            end

            ###
            # Initialize a new composer.json
            ###
            desc "init", "Initialize a new composer.json"
            def init
                run "composer init"
            end

            ###
            # Install packages
            #
            # You can specify a single package with `-p PACKAGE`, or `--package=PACKAGE`
            ###
            desc "install", "Install Composer packages"
            method_option :package, :default => nil, :aliases => "-p"
            def install
                if options[:package].nil?
                    ::ThemeJuice::warning "Installing Composer packages..."
                    if run "composer install"
                        ::ThemeJuice::success "Successfully installed Composer packages."
                    else
                        ::ThemeJuice::error "Failed to installed Composer packages. Be sure to run this command from your project root."
                    end
                else
                    ::ThemeJuice::warning "Installing `#{options[:package]}`..."
                    if run "composer install #{options[:package]}"
                        ::ThemeJuice::success "Successfully installed`#{options[:package]}`."
                    else
                        ::ThemeJuice::error "Failed to install `#{options[:package]}`. Be sure to run this command from your project root."
                    end
                end
            end

            ###
            # Update packages
            #
            # You can specify a single package with `-p PACKAGE`, or `--package=PACKAGE`
            ###
            desc "update", "Update Composer package"
            method_option :package, :default => nil, :aliases => "-p"
            def update
                if options[:package].nil?
                    ::ThemeJuice::warning "Updating Composer packages..."
                    if run "composer update"
                        ::ThemeJuice::success "Successfully updated Composer packages."
                    else
                        ::ThemeJuice::error "Failed to update Composer packages. Be sure to run this command from your project root."
                    end
                else
                    ::ThemeJuice::warning "Updating `#{options[:package]}`..."
                    if run "composer update #{options[:package]}"
                        ::ThemeJuice::success "Successfully updated `#{options[:package]}`."
                    else
                        ::ThemeJuice::error "Failed to update `#{options[:package]}`. Be sure to run this command from your project root."
                    end
                end
            end

            ###
            # Install composer packages
            #
            # @param {String} package
            ###
            desc "require", "Require packages from Composer"
            method_option :package, :default => nil, :aliases => "-p"
            def require
                if options[:package].nil?
                    ::ThemeJuice::warning "Requiring packages..."
                    if run "composer require"
                        ::ThemeJuice::success "Successfully required packages."
                    else
                        ::ThemeJuice::error "Failed to require packages. Be sure to run this command from your project root."
                    end
                else
                    ::ThemeJuice::warning "Requiring `#{options[:package]}`..."
                    if run "composer require #{options[:package]}"
                        ::ThemeJuice::success "Successfully required `#{options[:package]}`."
                    else
                        ::ThemeJuice::error "Failed to require `#{options[:package]}`. Be sure to run this command from your project root."
                    end
                end
            end

            ###
            # Remove a package
            #
            # @param {String} package
            ###
            desc "remove PACKAGE", "Remove PACKAGE from Composer"
            def remove(package)
                ::ThemeJuice::warning "Removing `#{package}`..."
                if run "composer remove #{package}"
                    ::ThemeJuice::success "Successfully removed `#{package}`."
                else
                    ::ThemeJuice::error "Failed to remove `#{package}`. Be sure to run this command from your project root."
                end
            end
        end
    end
end
