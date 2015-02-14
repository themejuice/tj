# encoding: UTF-8

module ThemeJuice
    class Service::DeleteSite < ::ThemeJuice::Service

        #
        # @param {Hash} opts
        #
        def initialize(opts)
            opts = ThemeJuice::Interaction::DeleteSiteOptions.new.get_site_options(opts)

            super
        end

        #
        # Remove all traces of site from Vagrant
        #
        # @return {Void}
        #
        def delete
            @interaction.speak "Are you sure you want to delete '#{@opts[:site_name]}'? (y/N)", {
                color: [:white, :on_red],
                icon: :notice,
                row: true
            }

            if @interaction.agree? "", { color: :red, simple: true }

                steps = {
                    remove_dev_site:      :dev_site_is_setup?,
                    remove_database:      :database_is_setup?,
                    remove_synced_folder: :synced_folder_is_setup?,
                }

                steps.each do |action, condition|
                    send "#{action}" if send "#{condition}"
                end

                if removal_was_successful?
                    @interaction.success "Site '#{@opts[:site_name]}' successfully removed!"

                    if @opts[:restart]
                        restart_vagrant
                    end
                else
                    @interaction.error "Site '#{@opts[:site_name]}' could not be fully be removed."
                end
            end
        end

        private

        #
        # Remove all theme files from Vagrant directory
        #
        # @return {Void}
        #
        def remove_dev_site

            unless Dir.entries("#{@environment.vvv_path}").include? "www"
                @interaction.error "Cannot load VVV path. Aborting mission before something bad happens."
            end

            if run ["rm -rf #{@opts[:site_dev_location]}"]
                @interaction.speak "Development site successfully removed...", {
                    color: :yellow,
                    icon: :general
                }
            else
                @interaction.error "Site '#{@opts[:site_name]}' could not be removed. Make sure you have write capabilities to '#{@opts[:site_dev_location]}'."
            end
        end

        #
        # Remove database block from init-custom.sql
        #
        # @return {Void}
        #
        def remove_database
            if remove_traces_from_file "#{::ThemeJuice::Environment.vvv_path}/database/init-custom.sql"
                @interaction.speak "Database successfully removed...", {
                    color: :yellow,
                    icon: :general
                }
            end
        end

        #
        # Remove synced folder block from Vagrantfile
        #
        # @return {Void}
        #
        def remove_synced_folder
            if remove_traces_from_file "#{::ThemeJuice::Environment.vvv_path}/Vagrantfile"
                @interaction.speak "Synced folders successfully removed...", {
                    color: :yellow,
                    icon: :general
                }
            end
        end

        #
        # Remove all traces of auto-generated content from file
        #
        # @param {String} input_file
        #
        # @return {Void}
        #
        def remove_traces_from_file(input_file)
            begin
                # Create new tempfile
                output_file = Tempfile.new File.basename(input_file)
                # Copy over contents of actual file to tempfile
                open File.expand_path(input_file), "rb" do |file|
                    # Remove traces of theme from contents
                    output_file.write "#{file.read}".gsub(/(# Begin '#{@opts[:site_name]}')(.*?)(# End '#{@opts[:site_name]}')\n+/m, "")
                end
                # Move temp file to actual file location
                FileUtils.mv output_file, File.expand_path(input_file)
            rescue LoadError => err
                @interaction.error "#{err}"
            ensure
                # Make sure that the tempfile closes and is cleaned up, regardless of errors
                output_file.close
                output_file.unlink
            end
        end
    end
end
