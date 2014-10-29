module ThemeJuice
    module Tasks
        class WPCLI < ::Thor
            namespace :wpcli

            include ::Thor::Actions

            def self.banner(task, namespace = true, subcommand = false)
                "#{basename} #{task.formatted_usage(self, true, subcommand)}"
            end

            ###
            # Non Thor commands
            ###
            no_commands do

                ###
                # Check if WP-CLI is installed
                #
                # If it's not globally installed, this will prompt for an installation
                ###
                def installed?
                    unless ::ThemeJuice::installed? "wp"
                        ::ThemeJuice::error "WP-CLI doesn't seem to be installed, or is not globally executable."
                        answer = ask "Do you want to globally install it?", :limited_to => ["yes", "no"]

                        if answer == "yes"
                            ::ThemeJuice::warning "Installing WP-CLI..."
                            ::ThemeJuice::warning "This task uses `sudo` to move the installed `wp-cli.phar` into your `/usr/local/bin` so that it will be globally executable."
                            run [
                                "curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar",
                                "chmod +x wp-cli.phar",
                                "sudo mv wp-cli.phar /usr/local/bin/wp"
                            ].join " && "
                        else
                            ::ThemeJuice::warning "To use ThemeJuice, install WP-CLI manually and make sure it is globally executable."
                            exit -1
                        end
                    end
                end
            end

            ###
            # Setup
            ###
            desc "setup", "Install WP-CLI"
            def setup
                self.installed?
            end
        end
    end
end
