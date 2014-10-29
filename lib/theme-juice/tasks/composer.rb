module ThemeJuice
    module Tasks
        class Composer < ::Thor
            namespace :dependencies

            include ::Thor::Actions

            def self.banner(task, namespace = true, subcommand = false)
                "#{basename} #{task.formatted_usage(self, true, subcommand)}"
            end

            ###
            # Non Thor commands
            ###
            no_commands do

                ###
                # Check if Composer is installed
                #
                # If it's not globally installed, this will prompt for an installation
                ###
                def installed?
                    unless ::ThemeJuice::installed? "composer"
                        ::ThemeJuice::error "Composer doesn't seem to be installed, or is not globally executable."
                        answer = ask "Do you want to globally install it?", :limited_to => ["yes", "no"]

                        if answer == "yes"
                            ::ThemeJuice::warning "Installing Composer..."
                            ::ThemeJuice::warning "This task uses `sudo` to move the installed `composer.phar` into your `/usr/local/bin` so that it will be globally executable."
                            run [
                                "curl -sS https://getcomposer.org/installer | php",
                                "sudo mv composer.phar /usr/local/bin/composer"
                            ].join " && "
                        else
                            ::ThemeJuice::warning "To use ThemeJuice, install Composer manually and make sure it is globally executable."
                            exit -1
                        end
                    end
                end
            end

            ###
            # Setup
            ###
            desc "setup", "Install Composer"
            def setup
                self.installed?
            end

            ###
            # Install packages
            #
            # You can specify a single package with `-p PACKAGE`, or `--package=PACKAGE`
            ###
            desc "install", "Install Composer packages"
            method_option :package, :default => nil, :aliases => "-p"
            def install
                self.installed?

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
                self.installed?

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
                self.installed?

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
                self.installed?

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
