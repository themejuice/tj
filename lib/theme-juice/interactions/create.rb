# encoding: UTF-8

module ThemeJuice
    class Interaction::Create

        #
        # Set up interactions and environment
        #
        # @return {Void}
        #
        def initialize
            @environment = ::ThemeJuice::Environment
            @interaction = ::ThemeJuice::Interaction
        end

        #
        # Set up needed site options
        #
        # @param {Hash} opts
        #
        # @return {Hash}
        #
        def setup_site_options(opts = {})
            @opts = opts

            if @environment.yolo
                @opts[:use_defaults] = true
            end

            required_opts = [
                :site_name,
                :site_name_clean,
                :site_location,
                :site_starter_theme,
                :site_dev_location,
                :site_dev_url,
                :site_repository,
                :site_db_host,
                :site_db_name,
                :site_db_user,
                :site_db_pass
            ]

            required_opts.each do |opt|
                @opts[opt] = self.send "setup_#{opt}" unless @opts[opt]
            end

            # Verify that all the options are correct
            @interaction.list "Your settings :", :yellow, [
                "Site name: #{@opts[:site_name]}",
                "Site location: #{@opts[:site_location]}",
                "Starter theme: #{@opts[:site_starter_theme]}",
                "Development location: #{@opts[:site_dev_location]}",
                "Development url: http://#{@opts[:site_dev_url]}",
                "Initialized repository: #{@opts[:site_repository]}",
                "Database host: #{@opts[:site_db_host]}",
                "Database name: #{@opts[:site_db_name]}",
                "Database username: #{@opts[:site_db_user]}",
                "Database password: #{@opts[:site_db_pass]}"
            ]

            unless @interaction.agree? "Do the options above look correct?"
                @interaction.error "Dang typos... aborting mission."
            end

            @opts
        end

        private

        #
        # Site name
        #
        # @return {String}
        #
        def setup_site_name
            if @environment.yolo
                name = Faker::Company.bs.split(" ").sample.downcase
            else
                name = @interaction.prompt "What's the site name? (letters, numbers and dashes only)"
            end

            validate_site_name name

            name
        end

        #
        # Clean site name
        #
        # @return {String}
        #
        def setup_site_name_clean
            "#{@opts[:site_name]}".gsub(/[^\w]/, "_")[0..10]
        end

        #
        # Site local location
        #
        # @return {String}
        #
        def setup_site_location
            path = "#{Dir.pwd}/"

            if @opts[:use_defaults]
                location = File.expand_path(path)
            else
                location = File.expand_path(@interaction.prompt "Where do you want to setup the site?", :default => path, :path => true)
            end

            location
        end

        #
        # Site starter theme
        #
        # @return {String}
        #
        def setup_site_starter_theme
            if @opts[:site_bare]
                theme = false
            else
                themes = {
                    "theme-juice/theme-juice-starter" => "https://github.com/ezekg/theme-juice-starter.git",
                    "other" => nil,
                    "none"  => false
                }

                if @opts[:use_defaults]
                    return themes["theme-juice/theme-juice-starter"]
                end

                choice = @interaction.choose "Which starter theme would you like to use?", :blue, themes.keys

                case choice
                when "theme-juice/theme-juice-starter"
                    @interaction.success "Awesome choice!"
                when "other"
                    themes[choice] = @interaction.prompt "What is the repository URL for the starter theme that you would like to clone?"
                when "none"
                    @interaction.notice "Next time you need to create a site without a starter theme, you can just run the 'setup' command instead."
                    @opts[:site_bare] = true
                end

                theme = themes[choice]
            end

            theme
        end

        #
        # Site development location
        #
        # @return {String}
        #
        def setup_site_dev_location
            dev_location = File.expand_path("#{@environment.vvv_path}/www/tj-#{@opts[:site_name]}")
        end

        #
        # Site development url
        #
        # @return {String}
        #
        def setup_site_dev_url
            if @opts[:use_defaults]
                url = "#{@opts[:site_name]}.dev"
            else
                url = @interaction.prompt "What do you want the development url to be? (this should end in '.dev')", :default => "#{@opts[:site_name]}.dev"
            end

            validate_site_dev_url url

            url
        end

        #
        # Site repository
        #
        # @return {String}
        #
        def setup_site_repository
            if @opts[:use_defaults] || @opts[:skip_repo]
                repo = false
            else
                if @interaction.agree? "Would you like to initialize a new Git repository?"
                    repo = @interaction.prompt "What is the repository's URL?", :indent => 2
                else
                    repo = false
                end
            end

            repo
        end

        #
        # Database host
        #
        # @return {String}
        #
        def setup_site_db_host
            if @opts[:use_defaults] || @opts[:skip_db]
                db_host = "vvv"
            else
                db_host = @interaction.prompt "Database host", :default => "vvv"
            end

            db_host
        end

        #
        # Database name
        #
        # @return {String}
        #
        def setup_site_db_name
            if @opts[:use_defaults] || @opts[:skip_db]
                db_name = "#{@opts[:site_name_clean]}_db"
            else
                db_name = @interaction.prompt "Database name", :default => "#{@opts[:site_name_clean]}_db"
            end

            db_name
        end

        #
        # Database username
        #
        # @return {String}
        #
        def setup_site_db_user
            if @opts[:use_defaults] || @opts[:skip_db]
                db_user = "#{@opts[:site_name_clean]}_user"
            else
                db_user = @interaction.prompt "Database username", :default => "#{@opts[:site_name_clean]}_user"
            end

            db_user
        end

        #
        # Database password
        #
        # @return {String}
        #
        def setup_site_db_pass
            pass = Faker::Internet.password 24

            if @opts[:use_defaults] || @opts[:skip_db]
                db_pass = pass
            else
                db_pass = @interaction.prompt "Database password", :default => pass
            end

            db_pass
        end

        #
        # Validate site name
        #
        # @param {String} name
        #
        # @return {Void}
        #
        def validate_site_name(name)
            if name.empty?
                @interaction.error "Site name '#{name}' is invalid or empty. Aborting mission."
            end

            "#{name}".match /[^0-9A-Za-z.\-]/ do |char|
                @interaction.error "Site name contains an invalid character '#{char}'. This name is used for creating directories, so that's not gonna work. Aborting mission."
            end
        end

        #
        # Validate site url
        #
        # @param {String} url
        #
        # @return {Void}
        #
        def validate_site_dev_url(url)
            unless "#{url}".match /(.dev)$/
                @interaction.error "Your development url '#{url}' doesn't end with '.dev'. This is used internally by Landrush, so that's not gonna work. Aborting mission."
            end
        end
    end
end
