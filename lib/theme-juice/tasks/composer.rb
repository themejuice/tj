module ThemeJuice
    module Tasks
        class Composer < ::Thor
            namespace :vendor

            include ::Thor::Actions

            def self.banner(task, namespace = true, subcommand = false)
                "#{basename} #{task.formatted_usage(self, true, subcommand)}"
            end

            ###
            # Install packages
            #
            # You can specify a single package with `-p PACKAGE`, or `--package=PACKAGE`
            ###
            desc "install", "Install Composer packages"
            method_option :package, :default => nil, :aliases => "-p"
            def install
                # Install all packages if :packages is nil
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
                        ::ThemeJuice::error "Failed to installed `#{options[:package]}`. Be sure to run this command from your project root."
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
                # Update all packages if :packages is nil
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
            # Remove a package
            #
            # You must specify a single package with `-p PACKAGE`, or `--package=PACKAGE`
            ###
            desc "remove", "Remove Composer package"
            method_option :package, :required => true, :aliases => "-p"
            def remove
                ::ThemeJuice::warning "Removing `#{options[:package]}`..."
                if run "composer remove #{options[:package]}"
                    ::ThemeJuice::success "Successfully removed `#{options[:package]}`."
                else
                    ::ThemeJuice::error "Failed to remove `#{options[:package]}`. Be sure to run this command from your project root."
                end
            end

            ###
            # Install composer packages
            #
            # You can specify a single package with `-p PACKAGE`, or `--package=PACKAGE`
            ###
            desc "require", "Require new Composer packages"
            def require
                ::ThemeJuice::warning "Requiring new Composer packages..."
                if run "composer require"
                    ::ThemeJuice::success "Successfully required new Composer packages."
                else
                    ::ThemeJuice::error "Failed to require new Composer packages. Be sure to run this command from your project root."
                end
            end
        end
    end
end
