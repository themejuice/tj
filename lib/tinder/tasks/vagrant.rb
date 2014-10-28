module Tinder
    module Tasks
        class Vagrant < ::Thor
            namespace :vm

            include ::Thor::Actions

            def self.banner(task, namespace = true, subcommand = false)
                "#{basename} #{task.formatted_usage(self, true, subcommand)}"
            end

            ###
            # Non Thor commands
            ###
            no_commands do

                ###
                # Check if Vagrant is installed
                ###
                def installed?
                    unless ::Tinder::installed? "vagrant"
                        ::Tinder::error "Vagrant doesn't seem to be installed. Download Vagrant and VirtualBox before running this task. See README for more information."
                        exit -1
                    end
                end
            end

            ###
            # Start VM
            ###
            desc "up", "Start Vagrant"
            def up
                self.installed?

                ::Tinder::warning "Starting Vagrant..."
                run [
                    "cd ~/vagrant",
                    "vagrant up"
                ].join " && "
            end

            desc "start", "[Alias for `up`]"
            def start
                up
            end

            ###
            # Stop VM
            ###
            desc "halt", "Stop Vagrant"
            def halt
                self.installed?

                ::Tinder::warning "Stopping Vagrant..."
                run [
                    "cd ~/vagrant",
                    "vagrant halt"
                ].join " && "
            end

            desc "stop", "[Alias for `halt`]"
            def stop
                halt
            end

            ###
            # Restart VM
            ###
            desc "reload", "Restart Vagrant"
            def reload
                self.installed?

                ::Tinder::warning "Restarting Vagrant..."
                run [
                    "cd ~/vagrant",
                    "vagrant reload"
                ].join " && "
            end

            desc "restart", "[Alias for `reload`]"
            def restart
                reload
            end

            ###
            # Provision VM
            ###
            desc "provision", "Provision Vagrant"
            def provision
                self.installed?

                ::Tinder::warning "Provisioning Vagrant..."
                run [
                    "cd ~/vagrant",
                    "vagrant provision"
                ].join " && "
            end

            ###
            # Completely destroy VM
            ###
            desc "destroy!", "Destroy Vagrant"
            def destroy!
                self.installed?

                # Are you really, really sure?
                answer = ask "Are you sure you want to destroy the VM?",
                    :limited_to => ["yes", "no"]

                if answer == "yes"
                    ::Tinder::error "Destroying Vagrant..."
                    run [
                        "cd ~/vagrant",
                        "vagrant destroy"
                    ].join " && "
                end
            end

            ###
            # SSH
            ###
            desc "ssh", "SSH into Vagrant"
            def ssh
                self.installed?

                run [
                    "cd ~/vagrant",
                    "vagrant ssh"
                ].join " && "
            end
        end
    end
end
