module ThemeJuice
    module Tasks
        class Vagrant < ::Thor
            namespace :vm

            include ::Thor::Actions

            def self.banner(task, namespace = true, subcommand = false)
                "#{basename} #{task.formatted_usage(self, true, subcommand)}"
            end

            ###
            # Start VM
            ###
            desc "up", "Start Vagrant"
            def up
                ::ThemeJuice::warning "Starting Vagrant..."
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
                ::ThemeJuice::warning "Stopping Vagrant..."
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
                ::ThemeJuice::warning "Restarting Vagrant..."
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
                ::ThemeJuice::warning "Provisioning Vagrant..."
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
                # Are you really, really sure?
                answer = ask "Are you sure you want to destroy the VM?",
                    :limited_to => ["yes", "no"]

                if answer == "yes"
                    ::ThemeJuice::error "Destroying Vagrant..."
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
                run [
                    "cd ~/vagrant",
                    "vagrant ssh"
                ].join " && "
            end
        end
    end
end
